exports.utils = {
  isValidDate: (date) -> (date.getTime()) isnt 'NaN',

  showSelectOptions: (name, options, currentOptions) ->
    html = '<select size="' + (options.length + 1) + '" name="' + name + '[]" multiple="multiple">
      <option value="" class="title">Apps</option>'
    for option in options
      selected = ''
      for currentOption in currentOptions
        if option == currentOption
          selected = ' selected="selected"'
          break
    
      html += "<option value=\"#{option}\"#{selected}>#{option}</option>"

    html + "</select>"
}
