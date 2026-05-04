/**
 * @file js/articleFulltext.js
 *
 * Copyright (c) 2026 Simon Fraser University
 * Copyright (c) 2026 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Behaviour for the HTML galley fulltext view.
 *  Wraps galley images in click-to-zoom anchors, scrolls long tables,
 *  builds a TOC from <h2> headings, normalises reference whitespace and
 *  copyright text, and exposes an image modal. All DOM mutations use the
 *  DOM API (no innerHTML / no string concatenation of untrusted content).
 */
(function () {
    var smwInitialized = false;
    var smwObserver = null;
    var smwPollTimer = null;

    function smwModal(src) {
        var modal = document.getElementById('myModal');
        if (!modal) return;

        var img = document.getElementById('modalImg');
        if (img) img.setAttribute('src', src);
        modal.style.display = 'block';

        var closeBtn = modal.querySelector('.smw-image-modal__close');
        if (closeBtn) {
            closeBtn.onclick = function () {
                modal.style.display = 'none';
            };
        }
        modal.onclick = function (event) {
            if (event.target === modal) {
                modal.style.display = 'none';
            }
        };
    }

    function wrapImagesWithModalLink(articleBody) {
        var images = articleBody.getElementsByTagName('img');
        // Snapshot since we mutate the tree while iterating.
        var snapshot = Array.prototype.slice.call(images);
        for (var i = 0; i < snapshot.length; i++) {
            var imgTag = snapshot[i];
            if (imgTag.parentElement && imgTag.parentElement.tagName.toLowerCase() === 'a') continue;

            var imgSrc = imgTag.src;
            var wrapper = document.createElement('a');
            wrapper.id = 'fi_' + i;
            wrapper.className = 'mimage';
            wrapper.href = '#';
            wrapper.style.cursor = 'pointer';

			wrapper.addEventListener('click', function(e) {
				e.preventDefault();
				smwModal(imgSrc);
			});

            imgTag.parentNode.insertBefore(wrapper, imgTag);
            wrapper.appendChild(imgTag);
        }
    }

    function wrapTablesForOverflow(articleBody) {
        var tables = Array.prototype.slice.call(articleBody.getElementsByTagName('table'));
        for (var i = 0; i < tables.length; i++) {
            var tableTag = tables[i];
            var wrapper = document.createElement('div');
            wrapper.id = 'table' + (i + 1);
            wrapper.style.overflowX = 'auto';
            tableTag.parentNode.insertBefore(wrapper, tableTag);
            wrapper.appendChild(tableTag);
        }
    }

    function adjustNarrowTables(articleBody) {
        var tables = articleBody.getElementsByTagName('table');

		if (!tables.length) return;

		var tWidth = tables[0].offsetWidth;
        var tbodies = articleBody.getElementsByTagName('tbody');

		for (var i = 0; i < tbodies.length; i++) {
            var diff = tWidth - tbodies[i].offsetWidth;
            if (diff <= 3) continue;

			var container = document.getElementById('table' + (i + 1));
			if (!container) continue;

			var narrow = container.getElementsByTagName('table');
			if (!narrow.length) continue;

			narrow[0].classList.add('dynTable');
            narrow[0].style.borderWidth = '2px 2px 2px 2px';
        }
    }

    function trimReferenceWhitespace() {
        var refs = document.getElementsByClassName('ref');
        for (var i = 0; i < refs.length; i++) {
            normaliseTextNodes(refs[i]);
        }
    }

    function trimImageLabels() {
        var labels = document.getElementsByClassName('image-label');
        for (var i = 0; i < labels.length; i++) {
            // Trim leading/trailing whitespace inside the existing element
            // without touching child markup.
            normaliseTextNodes(labels[i], true);
        }
    }

    /**
     * Walks every text node within `el`, removing whitespace before commas
     * and periods. Operates on textContent so injected markup remains inert.
     * If `trimOuter` is true, also trims leading/trailing whitespace on the
     * first/last text nodes.
     */
    function normaliseTextNodes(el, trimOuter) {
        var walker = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, null);
        var first = null;
        var last = null;
        var node;
        while ((node = walker.nextNode())) {
            node.nodeValue = node.nodeValue
                .replace(/\s+,/g, ',')
                .replace(/\s+\./g, '.');
            if (!first) first = node;
            last = node;
        }
        if (trimOuter) {
            if (first) first.nodeValue = first.nodeValue.replace(/^\s+/, '');
            if (last) last.nodeValue = last.nodeValue.replace(/\s+$/, '');
        }
    }

    function addCorrespondenceLabel() {
        var notes = document.getElementsByClassName('author-notes');
        for (var i = 0; i < notes.length; i++) {
            if (notes[i].querySelector('.correspondence')) continue;
            var p = document.createElement('p');
            p.className = 'correspondence';
            p.style.fontWeight = 'bold';
            p.textContent = 'Correspondence';
            notes[i].insertBefore(p, notes[i].firstChild);
        }
    }

    function adjustShariffButtons() {
        var shariff = document.getElementsByClassName('shariff');
        for (var i = 0; i < shariff.length; i++) {
            shariff[i].setAttribute('data-button-style', 'icon');
        }
        var standard = document.getElementsByClassName('button-style-standard');
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

    function applyEnhancements() {
        var articleBody = document.getElementById('htmlContainer');
        if (!articleBody) return;

        wrapImagesWithModalLink(articleBody);
        wrapTablesForOverflow(articleBody);
        adjustNarrowTables(articleBody);
        trimReferenceWhitespace();
        trimImageLabels();
        addCorrespondenceLabel();
        adjustShariffButtons();
        trimCopyrightTrailingPeriod();
    }

    /**
     * Build a TOC from h2 headings entirely with DOM APIs — no HTML strings,
     * no innerHTML. The heading text is inserted via textContent, so even
     * if a galley contains hostile markup in a heading, it cannot escape.
     */
    function buildTOC() {
        var articleBody = document.getElementById('htmlContainer');
        var tocHost = document.getElementById('smwToc');
        if (!articleBody || !tocHost) return;

        var headings = articleBody.getElementsByTagName('h2');
        var list = document.createElement('ul');
        var hasItems = false;

        for (var i = 0; i < headings.length; i++) {
            var heading = headings[i];
            var anchorId = heading.id || null;

            if (!anchorId) {
                var inner = heading.querySelector('a[id], a[name]');
                if (inner) anchorId = inner.id || inner.getAttribute('name');
            }
            if (!anchorId) continue;

            var headingText = heading.textContent.trim();
            if (!headingText) continue;

            var li = document.createElement('li');
            var link = document.createElement('a');
            link.className = 'nav-link';
            link.setAttribute('href', '#' + anchorId);
            link.textContent = headingText;
            li.appendChild(link);
            list.appendChild(li);
            hasItems = true;
        }

        if (hasItems) {
            // Replace any prior TOC contents without an HTML string assignment.
            while (tocHost.firstChild) tocHost.removeChild(tocHost.firstChild);
            tocHost.appendChild(list);
        }
    }

    function hasContent() {
        var articleBody = document.getElementById('htmlContainer');
        if (!articleBody) return false;
        if (articleBody.getElementsByTagName('h2').length) return true;
        if (articleBody.getElementsByTagName('h1').length) return true;
        if (articleBody.getElementsByTagName('img').length) return true;
        return !!articleBody.querySelector('.article-meta, .abstract, .contrib-group');
    }

    function initializeContent() {
        if (smwInitialized) return true;
        if (!hasContent()) return false;

        smwInitialized = true;
        if (smwObserver) {
            smwObserver.disconnect();
            smwObserver = null;
        }
        if (smwPollTimer) {
            clearTimeout(smwPollTimer);
            smwPollTimer = null;
        }

        requestAnimationFrame(function () {
            requestAnimationFrame(function () {
                applyEnhancements();
                buildTOC();
            });
        });
        return true;
    }

    function startContentDetection() {
        var articleBody = document.getElementById('htmlContainer');
        if (!articleBody) return;
        if (initializeContent()) return;

        if (!smwObserver) {
            smwObserver = new MutationObserver(function () {
                initializeContent();
            });
            smwObserver.observe(articleBody, {
                childList: true,
                subtree: true,
                characterData: true
            });
        }

        (function poll() {
            if (smwInitialized) return;
            if (!initializeContent()) {
                smwPollTimer = setTimeout(poll, 50);
            }
        })();
    }

    function resetAndReinitialize() {
        smwInitialized = false;
        var tocHost = document.getElementById('smwToc');
        if (tocHost) {
            while (tocHost.firstChild) tocHost.removeChild(tocHost.firstChild);
        }
        startContentDetection();
    }

    document.addEventListener('visibilitychange', function () {
        if (document.visibilityState === 'visible' && !smwInitialized) {
            initializeContent();
        }
    });

    window.addEventListener('pageshow', function (event) {
        if (event.persisted) {
            resetAndReinitialize();
        } else {
            startContentDetection();
        }
    });

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', startContentDetection);
    } else {
        startContentDetection();
    }

    window.addEventListener('load', function () {
        if (!smwInitialized) startContentDetection();
    });

    // Expose the modal opener so any inline content that already references
    // `smwModal` keeps working.
    window.smwModal = smwModal;
})();
