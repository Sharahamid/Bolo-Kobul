# /.well-known/assetlinks.json: tells Android that the Bolo Kobul app from Google Play
# belongs to this website, so the app opens full-screen without a browser address bar.
# Set in config/application.yml:
#   ANDROID_PACKAGE_NAME: "com.bolokobul.app"
#   ANDROID_SHA256_FINGERPRINTS: "AB:CD:...,12:34:..."   (Play Console → Test and release →
#     App integrity → App signing; add the upload key's fingerprint too, comma separated)
class AssetLinksController < ActionController::Base
  def show
    package = ENV['ANDROID_PACKAGE_NAME'].to_s.strip
    fingerprints = ENV['ANDROID_SHA256_FINGERPRINTS'].to_s.split(',').map(&:strip).reject(&:blank?)
    statements = if package.present? && fingerprints.any?
                   [{ relation: ['delegate_permission/common.handle_all_urls'],
                      target: { namespace: 'android_app', package_name: package,
                                sha256_cert_fingerprints: fingerprints } }]
                 else
                   []
                 end
    expires_in 1.hour, public: true
    render json: statements
  end
end
