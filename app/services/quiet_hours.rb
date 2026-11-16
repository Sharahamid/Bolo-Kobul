# Quiet hours: no phone notifications or texts between 10 pm and 8 am Bangladesh time.
# They are kept (HeldMessage) and sent at 8 am by rake quiet_hours:release. Emails are
# not affected. Texts a member gets straight after their own action (sign-up code,
# "your 1st Kobul has been sent", purchase receipts) are not held: they are awake.
module QuietHours
  ZONE = 'Asia/Dhaka'.freeze
  START_HOUR = 22 # 10 pm
  END_HOUR = 8    # 8 am

  # Texts that reach someone because of what another member did, or from a nightly task
  HELD_SMS_KINDS = %w[kobul1_received kobul1_accepted kobul1_declined kobul1_expired
                      kobul2_received kobul2_accepted kobul2_declined text_alerts].freeze

  module_function

  def now?(time = Time.current)
    hour = time.in_time_zone(ZONE).hour
    hour >= START_HOUR || hour < END_HOUR
  end

  # true when the phone notification was kept for the morning
  def hold_push?(user_id, payload)
    return false unless now?

    HeldMessage.create!(channel: 'push', user_id: user_id, body: payload.to_json)
    true
  rescue StandardError => e
    Rails.logger.warn("[quiet hours] could not hold push for user #{user_id}: #{e.class}: #{e.message}")
    false
  end

  # true when the text was kept for the morning
  def hold_sms?(phone, msg, kind)
    return false unless now? && HELD_SMS_KINDS.include?(kind.to_s)

    HeldMessage.create!(channel: 'sms', phone: phone.to_s, body: msg.to_s, kind: kind.to_s)
    true
  rescue StandardError => e
    Rails.logger.warn("[quiet hours] could not hold #{kind} SMS: #{e.class}: #{e.message}")
    false
  end

  # 8 am: send everything that waited overnight. Phone notifications with the same tag
  # (e.g. several messages in one chat) go out once, the latest one.
  def release!(logger: Rails.logger)
    pushes = 0
    texts = 0
    HeldMessage.where(channel: 'push').order(:id).group_by(&:user_id).each do |user_id, rows|
      payloads = rows.map { |r| JSON.parse(r.body) rescue nil }.compact
      payloads.reverse.uniq { |p| p['tag'].presence || p.object_id }.reverse.each do |payload|
        WebPushJob.perform_now(user_id, payload, true)
        pushes += 1
      end
      HeldMessage.where(id: rows.map(&:id)).delete_all
    end
    HeldMessage.where(channel: 'sms').order(:id).find_each do |row|
      SmsService.call(row.phone, row.body, kind: row.kind.presence || :other, release: true)
      row.destroy
      texts += 1
    end
    logger.info("[quiet hours] released #{pushes} phone notification(s) and #{texts} text(s)")
    { pushes: pushes, texts: texts }
  end
end
