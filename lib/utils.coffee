exports.utils = {
  isValidDate: (date) -> date.getTime().toString() isnt 'NaN',
  capitalize: (str) -> str.charAt(0).toUpperCase() + str.slice(1),
  showSelectOptions: (name, options, currentOptions) ->
    html = '<select size="' + (options.length + 1) + '" name="' + name + '[]" multiple="multiple">
      <option value="" class="title">' + this.capitalize(name) + '</option>'
    for option in options
      selected = ''
      for currentOption in currentOptions
        if option == currentOption
          selected = ' selected="selected"'
          break
    
      html += "<option value=\"#{option}\"#{selected}>#{option}</option>"

    html + "</select>"
}
