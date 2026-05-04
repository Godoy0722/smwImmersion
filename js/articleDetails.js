/**
 * @file js/articleDetails.js
 *
 * Copyright (c) 2026 Simon Fraser University
 * Copyright (c) 2026 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Behaviour for the article landing page (article_details.tpl).
 *  Adjusts shariff buttons and trims trailing period in copyright info,
 *  using DOM APIs instead of innerHTML to avoid XSS.
 */
(function () {
    function adjustShariffButtons() {
        var shariff = document.getElementsByClassName('shariff');

		for (var i = 0; i < shariff.length; i++) {
            shariff[i].setAttribute('data-button-style', 'icon');
        }

		var standard = document.getElementsByClassName('button-style-standard');
        // Live HTMLCollection — iterate from the end while removing classes.
        for (var j = standard.length - 1; j >= 0; j--) {
            standard[j].classList.remove('button-style-standard');
        }
    }

    function trimCopyrightTrailingPeriod() {
        var rights = document.getElementsByClassName('copyright-info');
        for (var i = 0; i < rights.length; i++) {
            var paragraphs = rights[i].getElementsByTagName('p');
            if (paragraphs.length < 2) continue;
            var target = paragraphs[1];
            var text = (target.textContent || '').trim();
            if (text.length && text.charAt(text.length - 1) === '.') {
                target.textContent = text.slice(0, -1);
            }
        }
    }

    function init() {
        adjustShariffButtons();
        trimCopyrightTrailingPeriod();
    }

    // Wait until the rest of the page (incl. shariff widget) is settled.
    window.addEventListener('load', function () {
        setTimeout(init, 500);
    });
})();
