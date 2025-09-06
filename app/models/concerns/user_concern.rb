module UserConcern
  extend ActiveSupport::Concern

  USER_TYPE = {
      :Self => '0',
      :Parents => '1',
      :Sibling => '2',
      :Relative => '3',
      :Friend => '4',
      :Colleague => '5',
      :Other => '6'
  }


  EDUCATION_LEVEL = {
      :Doctorate => '0',
      :Graduate => '1',
      :Undergraduate => '2',
      :Intermediate => '3',
      :School => '4',
      :'Non-traditional Education' => '5',
      :Diploma => '6'
  }


  BOOLEAN_DATA = {
      :Yes => '0',
      :No => '1'
  }

  MOTHER_TONGUE = {
      :Bengali => '0',
      :Urdu => '1',
      :English => '2',
      :Hindi => '3',
      :French => '4',
      :Spanish => '5',
      :Arabic => '6',
      :Chinese => '7',
      :German => '8',
      :Others => '9'
  }

  NUMBER_OF_CHILDREN = {
      '0' => '0',
      '1' => '1',
      '2' => '2',
      '3' => '3',
      '4' => '4',
      '5' => '5',
      '6' => '6'
  }


  FOOD_HABITS = {
      :Vegetarian => '0',
      'Non Vegetarian' => '1',
      'Halal Food Always' => '2',
      'Halal Food When I Can' => '3',
      'Non-halal' => '4'
  }

  ISSUE_TYPES = {
      'Registration and Login' => '0',
      'Profile & Photo' => '1',
      'Partner - Searching and Contacting' => '2',
      'Finding matches' => '3',
      'Hide / Delete Profile' => '4',
      :Payments => '5',
      :Services => '6',
      :Refund => '7',
      'Privacy and confidentiality' => '8',
      'Report a Member' => '9',
      :Feedback => '10',
      :Queries => '11',
      :Others => '12'
  }

  EMPLOYMENT_STATUS = {
      'Full Time' => '0',
      'Part Time' => '1',
      :Contract => '2'
  }

  DESIGNATION = {
      :Employee => '0',
      :Worker => '1',
      :Director => '2',
      'Office holder' => '3',
      'Self-employed and contractor' => '4'
  }

  HAIR_COLOR = {
      :Black => '0',
      :Brown => '1',
      :Yellow => '2',
      :White => '3'
  }
  HAIR_TYPE = {
      :Plain => '0',
      :Curly => '1',
      :Other => '2'
  }

  RELATION = {
      :Father => '0',
      :Mother => '1',
      :Brother => '2',
      :Sister => '3',
      :Uncle => '4',
      :Aunt => '5',
      'Maternal Grandfather' => '6'
  }


  DRESS_STYLE = {
      'Jeans - T-Shirt' => '0',
      :Suit => '1',
      'Shirt -Pant' => '2',
      :Panjabi => '3',
      :Saree => '4',
      'Salwar-Kamij' => '5',
      :Other => '6'
  }

  LIVING_WITH = {
      :Alone => '0',
      :Kids => '1',
      'Kids- Spouse' => '2',
      :Parents => '3',
      :Pets => '4',
      'Roommate(s)' => '5',
      'Brother/Sister' => '6',
      'Uncle/Aunt' => '7',
      :Others => '8'
  }

  CUISINE = {
      "I'm a foodie" => '0',
      :Arabic => '1',
      :'Bengali' => '2',
      :Chinese => '3',
      :Continental => '4',
      :Gujarati => '5',
      :Indian => '6',
      :Italian => '7',
      :Mexican => '8',
      :Moghlai => '9',
      :Rajasthani => '10',
      'South Indian' => '11',
      :Sushi => '12',
      :Thai => '13',
      'Not a foodie!' => '14',
      :Other => '15'
  }


  HOBBIES = {
      :Acting => '0',
      :Astronomy => '1',
      :Astrology => '2',
      'Art / handicraft' => '3',
      :Collectibles => '4',
      :Cooking => '5',
      :Crosswords => '6',
      :Dancing => '7',
      'Film-making' => '8',
      :Fishing => '9',
      :Gardening => '10',
      :Landscaping => '11',
      :Graphology => '12',
      :Nature => '13',
      :Numerology => '14',
      :Painting => '15',
      :Palmistry => '16',
      :Pets => '17',
      :Photography => '18',
      'Playing musical instruments' => '19',
      :Puzzles => '20',
      :Sports => '21',
      :Antiques => '22',
      'Banknote Collecting' => '23',
      'Coins Collecting' => '23',
      :Drawing => '24',
      :Hunting => '25',
      'Newspaper Collecting' => '26',
      'Postcards Collecting' => '27',
      :Other => '28'
  }

  INTEREST = {
      'Adventure sports' => '0',
      'Book clubs' => '1',
      'Computer games' => '2',
      'Health & fitness' => '3',
      :Internet => '4',
      'Film-making' => '5',
      'Playing musical instruments' => '6',
      'Autograph Collecting' => '7',
      'Learning new languages' => '8',
      :Movies => '9',
      :Music => '10',
      :Politics => '11',
      :Reading => '12',
      'Social service' => '13',
      :Sports => '14',
      :Television => '15',
      :Theatre => '16',
      :Travel => '17',
      :Writing => '18',
      :Yoga => '19',
      'Alternative healing / medicine' => '20',
      :Astronomy => '21',
      :Shopping => '22',
      :Other => '23'
  }

  FAVOURITE_MUSIC = {
      :Blues => '0',
      :Devotional => '1',
      :Disco => '2',
      :Ghazals => '3',
      'Hip-Hop' => '4',
      'Heavy metal' => '5',
      'House music' => '6',
      'Indian classical' => '7',
      :Indipop => '8',
      :JazzPop => '9',
      :Qawalis => '10',
      :Rap => '11',
      'Film songs' => '12',
      :Reggae => '13',
      :Sufi => '14',
      'Western classical' => '15',
      'Country Music' => '16',
      :Band => '17',
      :Classic => '18',
      :Rock => '19',
      :Other => '20',
      "I'm not a music fan" => '21'
  }

  FAVOURITE_BOOK = {
      :Detective => '0',
      :Fiction => '1',
      :Thriller => '2',
      :Literature => '3',
      :Other => '4'
  }

  FAVOURITE_MOVIE = {
      :Action => '0',
      :Adventure => '1',
      :Documentary => '2',
      :Romantic => '3',
      :Other => '4'
  }

  FAVOURITE_CUISINE = {
      "I'm a foodie" => '0',
      :Arabic => '1',
      :Bengali => '2',
      :Chinese => '3',
      :Continental => '4',
      :Gujarati => '5',
      :Indian => '6',
      :Italian => '7',
      :Konkan => '8',
      :Mexican => '9',
      :Moghlai => '10',
      :Punjabi => '11',
      :Rajasthani => '12',
      'South Indian' => '13',
      :Sushi => '14',
      :Thai => '15',
      'Not a foodie!' => '16',
      :Other => '17'
  }

  FAVOURITE_TV_SHOW = {
      'Comedy Show' => '0',
      'Family Drama' => '1',
      'Magazine Show' => '2',
      :News => '3',
      :Documentary => '4',
      :Other => '5'
  }

  FITNESS_ACTIVITIES = {
      'Adventure sports' => '0',
      :Aerobics => '1',
      :Basketball => '2',
      :Badminton => '3',
      :Bowling => '4',
      'Billiards / snooker / pool' => '5',
      :Cricket => '6',
      :Cycling => '7',
      'Card games' => '8',
      :Carrom => '9',
      :Chess => '10',
      :Football => '11',
      :Golf => '12',
      :Hockey => '13',
      'Jogging / walking' => '14',
      'Martial arts' => '15',
      :Scrabble => '16',
      :Squash => '17',
      'Swimming / water sports' => '18',
      'Table-tennis' => '19',
      :Tennis => '20',
      :Volleyball => '21',
      'Weight Lifting' => '22',
      :Yoga => '23',
      :Meditation => '24',
      :Other => '25'
  }

  FAVOURITE_SPORTS = {
      :Athletics => '0',
      :Basketball => '1',
      :Cricket => '2',
      :Football => '3',
      :Hockey => '4',
      :Wrestling => '5',
      :Racing => '6',
      :Other => '7'
  }

  LANGUAGES = {
      :Bengali => '0',
      :Urdu => '1',
      :English => '2',
      :Hindi => '3',
      :French => '4',
      :Spanish => '5',
      :Arabic => '6',
      :Chinese => '7',
      :German => '8',
      :Others => '9'
  }

  NATIONALITIES = {
      :Bengali => '0',
      :Urdu => '1',
      :English => '2',
      :Hindi => '3',
      :French => '4',
      :Spanish => '5',
      :Arabic => '6',
      :Chinese => '7',
      :German => '8',
      :Others => '9'
  }

  TRAVEL = {
      :'Once a year' => '0',
      :'Once a month' => '1',
      :'Every weekend' => '2',
      :'Making every long weekend count' => '3',
      :Rarely => '4',
      :'Not a fan (love being home)' => '5',
      :Other => '6'
  }

  RELIGION = {
      :Islam => '0',
      :Hinduism => '1',
      :Christianity => '2',
      :Buddhism => '3',
      :Other => '4'
  }

  BORN_OR_REVERTED = {
      :Born => '0',
      :Reverted => '1',
  }

  def notification_msg
    if notifications.count.zero?
      'You have no unread message'
    else
      "Your have #{notifications.unread.count} unread message"
    end
  end
end