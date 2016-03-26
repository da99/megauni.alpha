
      collection( 'Clubs'  ) {
        asc( :filename )
        unique
      }

      collection( 'Failed_Log_In_Attempts' ) {
        desc(:date)
        desc(:ip_address)
        asc( :owner_id )
      }

      collection('Lifes') {
        asc :username
        unique
      }

      collection 'Member_Usernames' do
        asc :username
        unique
      end

      collection 'Messages' do
        asc :target_ids
        desc :parent_message_id
      end

      collection 'Message_Notifys' do
        asc :owner_id
        asc :message_id
      end

      collection 'Doc_Logs' do
        asc :doc_id
      end

