$(document).on 'turbolinks:load', ->
  $(document).on 'click', '.custom-modal-trigger', (e) ->
    _id = $(e.target).data('target')
    $("##{_id}").modal()
    $("##{_id}").modal('open')
  true