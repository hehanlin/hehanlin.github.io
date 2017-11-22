<div class="copyright">
    <div class="info">
        <span>&copy;</span>
        <span>1996 ~ {{ date(Date.now(), 'YYYY') }}</span>
        <span>❤</span>
        <span>{{ config.author }}</span>
    </div>
    {% if theme.visit_count %}
    <div class="visit_count">
        <i class="iconfont icon-visit"></i>
        <span id="busuanzi_value_site_uv"></span>
        <i class="iconfont icon-people"></i>
        <span id="busuanzi_value_site_pv"></span>
    </div>
    {% endif %}
</div>