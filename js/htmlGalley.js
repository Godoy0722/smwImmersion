/**
 * @file js/htmlGalley.js
 *
 * Copyright (c) 2026 Simon Fraser University
 * Copyright (c) 2026 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Fetches the HTML galley body and injects it into #htmlContainer.
 *  The remote document is parsed with DOMParser (which never executes
 *  scripts), and a safelist-based sanitiser strips any <script>, event-
 *  handler attributes and javascript: URLs before adoption. This avoids
 *  the XSS exposure of assigning unsanitised remote HTML to innerHTML.
 *
 *  Configuration: the galley download URL is read from
 *  #smwGalleyConfig[data-url] (rendered by display.tpl).
 */
(function () {
    var cfg = document.getElementById('smwGalleyConfig');
    var galleyUrl = cfg ? cfg.getAttribute('data-url') : null;
    if (!galleyUrl) return;

    var DANGEROUS_TAGS = {
        SCRIPT: 1,
        STYLE: 1,
        IFRAME: 1,
        OBJECT: 1,
        EMBED: 1,
        LINK: 1,
        META: 1,
        BASE: 1,
        FORM: 1
    };

    function sanitise(root) {
        var bad = root.querySelectorAll(Object.keys(DANGEROUS_TAGS).join(','));
        for (var i = bad.length - 1; i >= 0; i--) {
            bad[i].parentNode.removeChild(bad[i]);
        }

        var all = root.getElementsByTagName('*');
        for (var j = 0; j < all.length; j++) {
            var el = all[j];
            var attrs = el.attributes;
            for (var k = attrs.length - 1; k >= 0; k--) {
                var name = attrs[k].name;
                var value = attrs[k].value;
                if (name.toLowerCase().indexOf('on') === 0) {
                    el.removeAttribute(name);
                    continue;
                }
                if ((name === 'href' || name === 'src' || name === 'xlink:href') &&
                    /^\s*javascript:/i.test(value)) {
                    el.removeAttribute(name);
                }
            }
        }
        return root;
    }

    function styleGalley(container) {
        var images = container.querySelectorAll('img');
        for (var i = 0; i < images.length; i++) {
            var img = images[i];
            img.style.maxWidth = '100%';
            img.style.padding = '5px';
            img.style.marginBottom = '1rem';
            img.style.border = '1px solid #e8e8e8';
        }

        var bordered = container.querySelectorAll('table, td, th');
        for (var j = 0; j < bordered.length; j++) {
            bordered[j].style.border = '1px solid';
        }

        var titles = container.querySelectorAll('.page_title, .subtitle');
        for (var t = 0; t < titles.length; t++) {
			titles.remove();
            titles[t].parentNode.removeChild(titles[t]);
        }

        var paragraphs = container.querySelectorAll('p');
        if (paragraphs[1]) paragraphs[1].style.display = 'none';
    }

    function moveChildren(from, to) {
        while (to.firstChild) to.removeChild(to.firstChild);
        while (from.firstChild) to.appendChild(from.firstChild);
    }

    fetch(galleyUrl, { headers: { Accept: 'text/html' } })
        .then(function (response) { return response.text(); })
        .then(function (html) {
            var target = document.getElementById('htmlContainer');
            if (!target) return;

            // DOMParser does not execute <script> tags — safe to parse remote HTML.
            var doc = new DOMParser().parseFromString(html, 'text/html');
            var body = doc.body;
            if (!body) return;

            sanitise(body);
            styleGalley(body);
            moveChildren(body, target);
        })
        .catch(function () { });
})();
