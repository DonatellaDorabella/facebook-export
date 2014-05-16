request = require('request')
config = require('./config')
levelup = require('levelup')

# Module globals.
membersDb = {}
group_id = ""

requestMembers = (url) ->
  request(url, (error, response, body) ->
    if error
      console.log error
      # Shut everything down if there's an error. Almost certainly it means
      # the token is wrong or Facebook's API is having trouble.
      process.exit()
    members = JSON.parse body
    for member in members.data
      membersDb.put(member.id, member)
  )

module.exports = (program) ->
  # Explicitly list fields so can set comment limits to 999 which should fetch
  # all comments in one pass.
  url = "https://graph.facebook.com/#{ program.group_id }/members?access_token=#{ program.oauthToken }"
  membersDb = levelup(config.dataDir + '/group_members_' + program.group_id, { valueEncoding: 'json' })
  group_id = program.group_id
  requestMembers(url)
