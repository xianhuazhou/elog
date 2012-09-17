utils = {
  isValidDate: (date) -> date.getTime().toString() isnt 'NaN',
  capitalize: (str) -> str.charAt(0).toUpperCase() + str.slice(1),
  showSelectOptions: (name, options, currentOptions, cb = null) ->
    html = '<select size="' + (options.length + 1) + '" name="' + name + '[]" multiple="multiple">
      <option value="" class="title">' + utils.capitalize(name) + '</option>'
    for option in options
      selected = ''
      for currentOption in currentOptions
        if option == currentOption
          selected = ' selected="selected"'
          break
    
      if cb is null
        optionDisplay = option
      else
        optionDisplay = cb(option)

      html += "<option value=\"#{option}\"#{selected}>#{optionDisplay}</option>"

    html + "</select>"
  ,

  getLevelById: (levelId) ->
    switch levelId
      when 4 then 'Fatal'
      when 3 then 'Error'
      when 2 then 'Warning'
      when 1 then 'Info'
      when 0 then 'Debug'
  ,

  showDate: (date) ->
    year = date.getFullYear()
    month = date.getMonth() + 1
    day = date.getDate()
    hour = date.getHours()
    minute = date.getMinutes()
    second = date.getSeconds()

    month = '0' + month if month < 10
    day = '0' + day if day < 10
    hour = '0' + hour if hour < 10
    minute = '0' + minute if minute < 10
    second = '0' + second if second < 10

    return [year, month, day].join('-') + ' ' +
    [hour, minute, second].join(':')
}

exports.utils = utils
