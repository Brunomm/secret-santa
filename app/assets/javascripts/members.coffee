handleValidate = (e) ->
  $form  = $(e.target).parents('form:first')
  $email = $form.find('.member-mail')
  $name  = $form.find('.member-name')
  if valid_email($email.val()) && $name.val() != ""
    $form.submit()

$(document).on 'turbolinks:load', ->

  $(document).on 'keypress', '.member-name, .member-mail', (e) ->
    if e.which == 13
      handleValidate(e)

  $(document).on 'blur', '.member-name, .member-mail', (e) ->
    handleValidate(e)

  $('body').on 'click', 'a.remove_member', (e) ->
    $.ajax '/members/'+ e.currentTarget.id,
        type: 'DELETE'
        dataType: 'json',
        data: {}
        success: (data, text, jqXHR) ->
          Materialize.toast('Membro removido', 4000, 'green')
          $('#member_' + e.currentTarget.id).remove()
        error: (jqXHR, textStatus, errorThrown) ->
          Materialize.toast('Problema na remoção de membro', 4000, 'red')
    return false

  $(document).on 'submit', '.member-form', (e) ->
    e.preventDefault();
    $form  = $(e.target)
    if $form.data('submiting')
      return false
    else
      $form.data('submiting', true)

    method = if e.target.id == 'new_member' then 'POST' else 'PATCH'
    $.ajax e.target.action,
        type: method
        dataType: 'json',
        data: $form.serialize()
        success: (data, text, jqXHR) ->
          handleUpdateHtml(method, data['id'], data['name'],  data['email'])
          $('.new-member.member-name, .new-member.member-mail').val("")
          if method == 'POST'
            $('.new-member.member-name').focus()
          Materialize.toast('Membro salvo com sucesso', 4000, 'green')
          $form.data('submiting', false)
        error: (jqXHR, textStatus, errorThrown) ->
          Materialize.toast('Problema na hora de incluir membro', 4000, 'red')
    return false


valid_email = (email) ->
  /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(email)

handleUpdateHtml = (method, id, name, email) ->
  form_html = "<form class=\"edit_member member-form\" id=\"edit_member_#{id}\" action=\"/members/#{id}\" accept-charset=\"UTF-8\" method=\"post\" >"+
    '<div class="row">' +
      '<div class="col s12 m5 input-field">' +
        "<input id=\"name-#{id}\" type=\"text\" class=\"validate member-name\" name=\"member[name]\" value=\"#{name}\">" +
        "<label for=\"name-#{id}\" class=\"active\">Nome</label>" +
      '</div>' +
      '<div class="col s12 m5 input-field">' +
        "<input id=\"email-#{id}\" type=\"email\" class=\"validate member-mail\" name=\"member[email]\" value=\"#{email}\">" +
        "<label for=\"email-#{id}\" class=\"active\" data-error=\"Formato incorreto\">Email</label>" +
      '</div>' +
      '<div class="col s3 offset-s3 m1 input-field">' +
        '<i class="material-icons icon">visibility</i>' +
      '</div>' +
      '<div class="col s3 m1 input-field">' +
        '<a href="#" class="remove_member" id="' + id + '">' +
          '<i class="material-icons icon">delete</i>' +
        '</a>' +
      '</div>' +
    '</div>' +
  '</form>'
  if method == 'POST'
    $('.member_list').append('<div class="member" id="member_' + id + '">' +form_html+'</div>')
  else
    $("#member_#{id}").html(form_html)