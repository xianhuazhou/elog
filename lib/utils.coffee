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
}

exports.utils = utils
