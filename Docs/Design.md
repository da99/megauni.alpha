
* Architecture of Conversations

  Thread = Conversation = Message = Content = Object: logic + meta data(parend\_id) + content(title, body)
    |   (website | news article | event | project | private | random thought | magazine article | message/comment)
    | 
    | Authen. -> Authorization.
    | 
    CREATE:
    |     Validation:
    |       * Permission to comment on parent
    |       * Permission to create post
    | 
    READ:
    | 
    UPDATE:
    |     Validation:
    |       * Permission to edit post.
    |       * Permission for new parent_id?
    |       * Is new unique field unique?
    | 
    Trash:
        Authen. -> Authorization. -> Trash Notification
                                       | |
                                       \ /
      |----------------------------------------------------------------------|
      |                                                                      |
      \      An internal note on changes: added/removed people for read      /
       \  or edit capabilities, publish date changed, etc.                  /
        \                                                                  /
         |----------------------------------------------------------------|
                                       | |
                                       \ /
      |----------------------------------------------------------------------|
      |                                                                      |
      \   Related records are retrieved + Change Note +                      /
       \   Author. to read message is found  +                              /
        \   Should notif. be Crt/Updt/Del?                                 /
         |----------------------------------------------------------------|
                                Sorting
                                    |
                             |----------------|
                          INBOX | CHAT/BOT | Website 
                            /                  \
                    Mail | Event | River        River
                                       | |
                                       \ /
      |----------------------------------------------------------------------|
      |                                                                      |
      \            Notification is generated and                            /  
       \         saved to data store.                                      /
         |----------------------------------------------------------------|
                               
                              
            -------------------------- \
           /                            \
   Arch. of                              \
   Convers.   Content                     /  *Everything becomes a threaded conversation:*
          \   Subscriptions               /     websites, events, random thoughts, magazine articles, priv. mess., etc.
           \  Notification               /   Exceptions: update history
            ---------------------------      Each object is stored with in the datastore as:
                                                 content(title, body, etc.) + 
                                                 meta(parent_id, created_at, published_at)
                                                 logic(validation, privacy, who can post comments, etc.)
                            

  * Lifes Inboxs
    
    all: 
      Stream of messages:
        [Text]
      [Unfollow website/author.] [Archive it.] [Quote it.]
                
    1: stream
    
      Priv. Mess.
        Write
        
      Drafts
      
      Website
        Write
        Settings
        
      Website
        Write
        Settings
        
      Trash
      
      Archive
        New Folder
        
      Settings: 
                Delete Life
                Change Username
      People
        Fans
        Friends
        Enemies
        [New Group]
      
    2: stream
      [expand]

    [New Life]
    [New Website]

    [Addons]
    [Mass Market Friend-to-Friend] $20-$60/mo
    [New Unibot]
    [etc].

    Account Settings:
  
  * chatroom
    * unibots
    * follow
    * multi-conversations/rooms
