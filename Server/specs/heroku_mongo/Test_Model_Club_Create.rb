


class Test_Club_Create < Test::Unit::TestCase

  def random_filename
    "movie_#{rand(10000)}"
  end

  must 'require a filename' do
    club = begin
             Club.create(
               admin_member, 
               { :filename=>nil,
                 :title=>'Gaijin', 
                 :teaser=>'Gaijin'}
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal 'Filename is required.', club.errors.first
  end
  
  must 'require a unique filename' do
    filename = Club.find_one({}).data.filename
    old_filename = create_club.data.filename
    club = begin
             Club.create( admin_member,
              {:filename=>old_filename, :title=>'title', :teaser=>'teaser'} 
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal "Filename, #{old_filename}, already taken. Please choose another.", club.errors.first
  end

  must 'use a safe insert into Clubs collection.' do
    Club.db.collection.expects(:insert).returns('new_id').with do |doc, opts|
      opts[:safe] === true
    end
    create_club
  end

  must 'require a title' do
    club = begin
             Club.create(
               admin_member, 
               { :filename=>random_filename, 
                 :title => nil, 
                 :teaser=>'Gaijin'}
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal 'Title is required.', club.errors.first
  end

  must 'require a teaser' do
    club = begin
             Club.create(
               admin_member, 
               { :filename=>random_filename, 
                 :title=>'Gaijin',
                 :teaser=> nil
                 }
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal 'Teaser is required.', club.errors.first

  end

  must 'set "en-us" as the language.' do
    club = Club.create(
            admin_member, 
            {:filename=>random_filename, 
             :title=>'Gaijin',
             :teaser=>'Relaxed'}
    )
    assert_equal 'en-us', club.data.lang
  end


end # === _create
