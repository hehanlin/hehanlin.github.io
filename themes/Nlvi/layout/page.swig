{% extends "_layout.swig" %}
{% import '_partial/post.swig' as postt %}


{% block main %}
    {{ postt.render(page) }}
{% endblock %}