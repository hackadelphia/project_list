$(document).ready(function() {
  // XXX with exception to the ajax call that gets the items, ripped wholesale from jquery ui docs.
  var availableTags = [];
  $.getJSON('/ajax/list/techs', {}, function(data) { availableTags = data });

  function split(val) {
    return val.split(/\s*,\s*/);
  }

  function extractLast(term) {
    return split(term).pop();
  }
  
  $(".tech_complete").autocomplete({
    minLength: 2,
    source: function(request, response) {
      // delegate back to autocomplete, but extract the last term
      response($.ui.autocomplete.filter(availableTags, extractLast(request.term)));
    },
    focus: function() {
      // prevent value inserted on focus
      return false;
    },
    select: function(event, ui) {
      var terms = split( this.value );
      // remove the current input
      terms.pop();
      // add the selected item
      terms.push( ui.item.value );
      // add placeholder to get the comma-and-space at the end
      terms.push("");
      this.value = terms.join(", ");
      return false;
    }
  });
});
