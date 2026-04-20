{**
 * templates/frontend/objects/article_details.tpl
 *
 * Copyright (c) 2026 Simon Fraser University
 * Copyright (c) 2026 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief View of an Article which displays all details about the article.
 *  Expected to be primary object on the page.
 *
 * Many journals will want to add custom data to this object, either through
 * plugins which attach to hooks on the page or by editing the template
 * themselves. In order to facilitate this, a flexible layout markup pattern has
 * been implemented. If followed, plugins and other content can provide markup
 * in a way that will render consistently with other items on the page. This
 * pattern is used in the .main_entry column and the .entry_details column. It
 * consists of the following:
 *
 * <!-- Wrapper class which provides proper spacing between components -->
 * <div class="item">
 *     <!-- Title/value combination -->
 *     <div class="label">Abstract</div>
 *     <div class="value">Value</div>
 * </div>
 *
 * All styling should be applied by class name, so that titles may use heading
 * elements (eg, <h3>) or any element required.
 *
 * <!-- Example: component with multiple title/value combinations -->
 * <div class="item">
 *     <div class="sub_item">
 *         <div class="label">DOI</div>
 *         <div class="value">12345678</div>
 *     </div>
 *     <div class="sub_item">
 *         <div class="label">Published Date</div>
 *         <div class="value">2015-01-01</div>
 *     </div>
 * </div>
 *
 * <!-- Example: component with no title -->
 * <div class="item">
 *     <div class="value">Whatever you'd like</div>
 * </div>
 *
 * Core components are produced manually below, but can also be added via
 * plugins using the hooks provided:
 *
 * Templates::Article::Main
 * Templates::Article::Details
 *
 * @uses $article Article This article
 * @uses $publication Publication The publication being displayed
 * @uses $firstPublication Publication The first published version of this article
 * @uses $currentPublication Publication The most recently published version of this article
 * @uses $issue Issue The issue this article is assigned to
 * @uses $section Section The journal section this article is assigned to
 * @uses $primaryGalleys array List of article galleys that are not supplementary or dependent
 * @uses $supplementaryGalleys array List of article galleys that are supplementary
 * @uses $keywords array List of keywords assigned to this article
 * @uses $pubIdPlugins Array of pubId plugins which this article may be assigned
 * @uses $licenseTerms string License terms.
 * @uses $licenseUrl string URL to license. Only assigned if license should be
 *   included with published articles.
 * @uses $ccLicenseBadge string An image and text with details about the license
 *}
<section class="col-md-8 article-page">
    <header class="article-page__header">
        {* Notification that this is an old version *}
    </header>

    <div class="article-page__meta">
        <dl>
            {* Pub IDs, including DOI *}
             {* DOI (requires plugin) *}
             {assign var=doiObject value=$article->getCurrentPublication()->getData('doiObject')}
             {if $doiObject}
                <dt>
                    DOI:
                </dt>
                <dd>
                    {assign var="doiUrl" value=$doiObject->getData('resolvingUrl')|escape}
                    <a href="{$doiUrl}" class="text-decoration-none">
                        {$doiUrl}
                    </a>
                </dd>
             {/if}

            <dt>
                Cite this as:
            </dt>
            <dd>
                <span id="citestring" style="">
					{$currentJournal->getLocalizedName()}
					{if $issue->getYear()} {$issue->getYear()}{/if}
					{if $issue->getVolume()}{if $issue->getYear()};{/if}{translate key="issue.vol"} {$issue->getVolume()}{/if}
					{if $publication->getData('pages')}:{$publication->getData('pages')}{/if}
				</span>
            </dd>
        </dl>
    </div><!-- .article-page__meta-->

    {* Hook for plugins under the main block, like Recommend Articles by Author *}
    {call_hook name="Templates::Article::Main"}

    <!-- sub-oh Hierhin kommt der Inhalt der HTML-Datei -->
    <div class="item" id="htmlContainer" style="padding: 0;">
        <div style="padding: 30px; display: none;">
            <i class="fa fa-spinner fa-spin" style="font-size: 3em;"></i>
            <p>To see the page, Javascript must be enabled.</p>
            {assign var="articleId" value=$article->getBestId()}
            <p>
                Alternatively (2), you can download the
                <a href="{url page="article" op="download" path=$articleId|to_array:$galley->getBestGalleyId() inline=true}">
                    raw html article
                </a>
            </p>
        </div>
    </div>
</section>

<aside class="col-md-4 offset-lg-1 col-lg-3 article-sidebar">
    {include file="frontend/components/article_sidebar.tpl"}

    <!-- side nav to be assembled by js -->
    <div id="smwToc" class="sidetoc"></div>
</aside>

<!-- The Modal -->
<div id="myModal" class="smw-image-modal">
    <!-- Modal content -->
    <div class="smw-image-modal__content">
        <span class="smw-image-modal__close" style="color:#04692a;">&times;</span>
        <div>
            <img id="modalImg" src="" style="max-width: 100%;">
        </div>
    </div>
</div>

<style>
    html {
        scroll-behavior: smooth;
        scroll-padding-top: 3rem;
    }

    h1 {
        font-size: 2.25rem;
        margin-top: 1rem;
    }

    h4 {
        font-weight: normal;
        margin-top: 1.5rem;
    }

    .article-page a {
        color: #041469;
    }

    main a:after,
    aside a:after {
        border-bottom: 1px solid #041469;
    }

    table {
        width: 100%;
        margin-bottom: 1rem;
        display: block;
        overflow-x: auto;
    }

    .dynTable {
        border: 2 px;
        display: inline-table !important;
    }

    th,
    td {
        padding: 5px;
        font-family: 'Inter', sans-serif;
        /* word-break: break-word; */
    }

    .table-wrap-foot,
    .table-caption {
        font-size: smaller;
    }

    .table-caption .label {
        font-weight: bold;
    }

    .table-caption .label::after {
        content: ". ";
    }

    .image-label {
        font-weight: bold;
    }

    .image-label::after {
        content: ". ";
    }

    .fn .label {
        font-weight: bold;
    }

    aside > figure > img {
        height: 255px !important;
        width: 255px !important;
    }

    ul,
    ol {
        padding-inline-start: 18px;
    }

    p.correspondence {
        margin-bottom: 0;
        line-height: 1.4rem;
    }

    div.fig {
        font-size: smaller;
    }

    div.author-notes {
        margin-bottom: 0;
        line-height: 1.4rem;
    }

    #htmlContainer > div.article-meta > p > sup {
        margin-right: 0.25rem !important;
    }

    .sidetoc {
        margin-left: -15px;
        margin-right: -15px;
        background-color: #f2f2f2;
        padding-top: 15px;
        padding-bottom: 15px;
        position: -webkit-sticky;
        position: sticky;
        top: 0;
    }

    .sidetoc a {
        text-rendering: optimizeLegibility;
        font-size: 0.85rem;
        list-style: none;
        line-height: 1.5;
        font-family: 'Inter', sans-serif;
        font-weight: 400;
        text-align: left;
        /* white-space: nowrap; */
        box-sizing: border-box;
        text-decoration: none;
        background-color: transparent;
        display: block;
        box-shadow: none;
        margin-left: 0;
        padding: 5px 8px 4px 8px;
        color: #1b8798;
        border: 1px solid #f2f2f2;
    }

    .sidetoc a:hover,
    .sidetoc a:active,
    .sidetoc a:focus {
        color: #1b8798;
        background-color: #e8e8e8;
        border: 1px solid #1b8798;
    }

    .sidetoc ul {
        list-style-type: none;
        margin: 0;
        padding: 0;
    }

    .sidetoc li {
        margin-left: 1rem;
        margin-right: 1rem;
        text-align: center;
        overflow: clip;
    }

    .bullet li {
        list-style-type: disc !important;
    }

    #htmlContainer li {
        list-style-type: auto;
    }

    .ref {
        font-size: 16px;
    }

    .altmetric-embed img {
        height: 80px;
        width: 80px;
    }

    .__dimensions_Badge_Image {
        height: 80px !important;
        width: 80px !important;
    }

    .exlink a {
        background-color: #24B6CD !important;
        border: 1px solid #24B6CD;
        font-weight: 600;
        color: #000 !important;
        padding: 6px 12px;
    }

    .exlink a:hover {
        background-color: #fff !important;
        border: 1px solid #000;
        color: #000;
    }

    .mimage {
        cursor: pointer !important;
    }

    .mimage img {
        cursor: pointer !important;
    }

	.smw-image-modal {
		display: none; /* Hidden by default */
		position: fixed; /* Stay in place */
		z-index: 1050; /* Sit on top */
		left: 0;
		top: 0;
		width: 100%; /* Full width */
		height: 100%; /* Full height */
		overflow: auto; /* Enable scroll if needed */
		background-color: rgb(0,0,0); /* Fallback color */
		background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
	}

		/* Modal Content/Box */
	.smw-image-modal__content {
		background-color: #fefefe;
		margin: 15% auto; /* 15% from the top and centered */
		padding: 20px;
		border: 1px solid #888;
		width: 80%; /* Could be more or less, depending on screen size */
	}

		/* The Close Button */
	.smw-image-modal__close {
		color: #aaa;
		float: right;
		font-size: 28px;
		font-weight: bold;
	}

	.smw-image-modal__close:hover,
	.smw-image-modal__close:focus {
		color: black;
		text-decoration: none;
		cursor: pointer;
	}
</style>

<script>
	function smwModal(src) {
        // Get the modal
        var modal = document.getElementById("myModal");
        // display correct image
        document.getElementById("modalImg").src = src;
        modal.style.display = "block";

        // Get the <span> element that closes the modal (specifically for this modal)
        var closeBtn = modal.querySelector(".smw-image-modal__close");

        // When the user clicks on <span> (x), close the modal
        if (closeBtn) {
            closeBtn.onclick = function() {
                modal.style.display = "none";
            };
        }

        // When the user clicks anywhere outside of the modal, close it
        modal.onclick = function(event) {
            if (event.target === modal) {
                modal.style.display = "none";
            }
        };
    }

    (function() {
        var smwInitialized = false;
        var smwObserver = null;
        var smwPollTimer = null;

        function myReplaceFunction() {
            var articleBody = document.getElementById("htmlContainer");
            if (!articleBody) return;

            // wrap modal link around images
            let articleImages = articleBody.getElementsByTagName("img");
            for (let i = 0; i < articleImages.length; i++) {
                let imgTag = articleImages[i];
                // Skip if image is already inside an <a> tag
                if (imgTag.parentElement && imgTag.parentElement.tagName.toLowerCase() === "a") {
                    continue;
                }
                let imgSrc = imgTag.src;

                // Create wrapper anchor element
                let wrapperLink = document.createElement("a");
                wrapperLink.id = "fi_" + i;
                wrapperLink.className = "mimage";
                wrapperLink.href = "#";
                wrapperLink.style.cursor = "pointer";

                // Add click event listener instead of inline javascript
                wrapperLink.addEventListener('click', function(e) {
                    e.preventDefault();
                    smwModal(imgSrc);
                });

                // Insert the wrapper before the image and move the image inside
                imgTag.parentNode.insertBefore(wrapperLink, imgTag);
                wrapperLink.appendChild(imgTag);
            }

            // wrap div around tables
            var articleTables = articleBody.getElementsByTagName("table");
            for (let i = 0; i < articleTables.length; i++) {
                var tableTag = articleTables[i];
                var j = i + 1;

                // Create wrapper div
                var wrapperDiv = document.createElement("div");
                wrapperDiv.id = "table" + j;
                wrapperDiv.style.overflowX = "auto";

                // Insert wrapper before table and move table inside
                tableTag.parentNode.insertBefore(wrapperDiv, tableTag);
                wrapperDiv.appendChild(tableTag);
            }

            // measure width of tables, adjust if necessary
            var articleTwidths = articleBody.getElementsByTagName("table");
            if (articleTwidths.length > 0) {
                var tWidth = articleTwidths[0].offsetWidth;

                var articleTbodies = articleBody.getElementsByTagName("tbody");
                for (let i = 0; i < articleTbodies.length; i++) {
                    var tbWidth = articleTbodies[i].offsetWidth;
                    var wDiff = tWidth - tbWidth;

                    // adjust display property
                    if (wDiff > 3) {
                        // div name
                        var j = i + 1;
                        var divname = 'table' + j;
                        var divContainer = document.getElementById(divname);
                        if (divContainer) {
                            var narrowTable = divContainer.getElementsByTagName('table');
                            if (narrowTable.length > 0) {
                                narrowTable[0].classList.add('dynTable');
                                narrowTable[0].style.borderWidth = '2px 2px 2px 2px';
                            }
                        }
                    }
                }
            }

            // remove space before commas and periods in reference list
            var rlist = document.getElementsByClassName("ref");
            for (let i = 0; i < rlist.length; i++) {
                var reftext = rlist[i].innerHTML;
                reftext = reftext.replace(/[\s]+,/g, ",");
                reftext = reftext.replace(/[\s]+\./g, ".");
                reftext = reftext.trim();
                rlist[i].innerHTML = reftext;
            }

            // trim image labels
            var ilabellist = document.getElementsByClassName("image-label");
            for (let i = 0; i < ilabellist.length; i++) {
                var ilabeltext = ilabellist[i].innerHTML;
                ilabeltext = ilabeltext.trim();
                ilabellist[i].innerHTML = ilabeltext;
            }

            // add correspondence label
            var authorNotesElements = document.getElementsByClassName("author-notes");
            for (let i = 0; i < authorNotesElements.length; i++) {
                // Check if correspondence label already exists
                var existingCorrespondence = authorNotesElements[i].querySelector('.correspondence');
                if (!existingCorrespondence) {
                    var correspondenceP = document.createElement("p");
                    correspondenceP.className = "correspondence";
                    correspondenceP.style.fontWeight = "bold";
                    correspondenceP.textContent = "Correspondence";
                    authorNotesElements[i].insertBefore(correspondenceP, authorNotesElements[i].firstChild);
                }
            }

            // adjust shariff buttons
            var shariff = document.getElementsByClassName("shariff");
            for (let i = 0; i < shariff.length; i++) {
                shariff[i].setAttribute("data-button-style", "icon");
            }
            var shList = document.getElementsByClassName("button-style-standard");
            for (let i = 0; i < shList.length; i++) {
                shList[i].classList.remove("button-style-standard");
            }

            // remove trailing period in copyright info
            var cright = document.getElementsByClassName("copyright-info");
            for (let i = 0; i < cright.length; i++) {
                var element = cright[i];
                var nodes = element.getElementsByTagName("p");
                if (nodes.length > 1 && nodes[1].innerHTML) {
                    var crstring = nodes[1].innerHTML;
                    crstring = crstring.substring(0, crstring.length - 1);
                    nodes[1].innerHTML = crstring;
                }
            }
        }

        function smwTOC() {
            var articleBody = document.getElementById("htmlContainer");
            var smwTocElement = document.getElementById("smwToc");
            if (!articleBody || !smwTocElement) return;

            var tocsections = articleBody.getElementsByTagName("h2");
            var tocItems = '<ul>';
            var hasItems = false;

            for (let i = 0; i < tocsections.length; i++) {
                var h2Element = tocsections[i];
                var anchorId = null;
                var headingText = '';

                // Method 1: Check if h2 itself has an id attribute
                if (h2Element.id) {
                    anchorId = h2Element.id;
                    headingText = h2Element.textContent.trim();
                }

                // Method 2: Check for <a id="xxx"></a> inside h2
                if (!anchorId) {
                    var anchorMatch = h2Element.innerHTML.match(/<a\s+id=["']([^"']+)["'][^>]*><\/a>/i);
                    if (anchorMatch) {
                        anchorId = anchorMatch[1];
                        headingText = h2Element.textContent.trim();
                    }
                }

                // Method 3: Check for <a name="xxx"></a> inside h2
                if (!anchorId) {
                    var nameMatch = h2Element.innerHTML.match(/<a\s+name=["']([^"']+)["'][^>]*><\/a>/i);
                    if (nameMatch) {
                        anchorId = nameMatch[1];
                        headingText = h2Element.textContent.trim();
                    }
                }

                // Method 4: Check for any <a> with id inside h2
                if (!anchorId) {
                    var innerAnchor = h2Element.querySelector('a[id]');
                    if (innerAnchor) {
                        anchorId = innerAnchor.id;
                        headingText = h2Element.textContent.trim();
                    }
                }

                // Create TOC item if we found an anchor
                if (anchorId && headingText) {
                    tocItems += '<li><a class="nav-link" href="#' + anchorId + '">' + headingText + '</a></li>';
                    hasItems = true;
                }
            }

            tocItems = tocItems + "</ul>";

            if (hasItems) {
                smwTocElement.innerHTML = tocItems;
            }
        }

        function hasContent() {
            var articleBody = document.getElementById("htmlContainer");
            if (!articleBody) return false;

            // Check for actual galley content - h2 elements are the most reliable indicator
            // since placeholder content doesn't have h2 elements
            var h2Elements = articleBody.getElementsByTagName("h2");
            if (h2Elements.length > 0) {
                return true;
            }

            // Also check for h1 (article title) which appears in the loaded content
            var h1Elements = articleBody.getElementsByTagName("h1");
            if (h1Elements.length > 0) {
                return true;
            }

            // Check for images loaded from the galley (not placeholder images)
            // The placeholder has no images
            var images = articleBody.getElementsByTagName("img");
            if (images.length > 0) {
                return true;
            }

            // Check for article-specific classes that only appear in loaded content
            var articleMeta = articleBody.querySelector('.article-meta, .abstract, .contrib-group');
            if (articleMeta) {
                return true;
            }

            return false;
        }

        function initializeContent() {
            if (smwInitialized) return true;

            if (hasContent()) {
                smwInitialized = true;

                // Stop observer and polling
                if (smwObserver) {
                    smwObserver.disconnect();
                    smwObserver = null;
                }
                if (smwPollTimer) {
                    clearTimeout(smwPollTimer);
                    smwPollTimer = null;
                }

                // Use requestAnimationFrame to ensure DOM is stable
                // This allows any ongoing DOM mutations to complete
                requestAnimationFrame(function() {
                    requestAnimationFrame(function() {
                        myReplaceFunction();
                        smwTOC();
                    });
                });
                return true;
            }
            return false;
        }

        function startContentDetection() {
            var articleBody = document.getElementById("htmlContainer");
            if (!articleBody) return;

            // Try immediate initialization first
            if (initializeContent()) return;

            // Set up MutationObserver for dynamic content
            if (!smwObserver) {
                smwObserver = new MutationObserver(function(mutations) {
                    // Check for meaningful content on any DOM change
                    initializeContent();
                });

                smwObserver.observe(articleBody, {
                    childList: true,
                    subtree: true,
                    characterData: true
                });
            }

            // Polling fallback with shorter initial interval
            function pollForContent() {
                if (!smwInitialized) {
                    if (!initializeContent()) {
                        smwPollTimer = setTimeout(pollForContent, 50);
                    }
                }
            }
            pollForContent();
        }

        function resetAndReinitialize() {
            // Reset state for bfcache restoration
            smwInitialized = false;

            // Clear TOC to rebuild it fresh
            var smwTocElement = document.getElementById("smwToc");
            if (smwTocElement) {
                smwTocElement.innerHTML = '';
            }

            startContentDetection();
        }

        // Handle page visibility changes (tab switching, etc.)
        document.addEventListener('visibilitychange', function() {
            if (document.visibilityState === 'visible' && !smwInitialized) {
                initializeContent();
            }
        });

        // Handle bfcache restoration (back/forward navigation)
        window.addEventListener('pageshow', function(event) {
            if (event.persisted) {
                // Page was restored from bfcache
                resetAndReinitialize();
            } else {
                // Normal page load
                startContentDetection();
            }
        });

        // DOMContentLoaded - fires when HTML is parsed (earlier than load)
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', startContentDetection);
        } else {
            // DOM already loaded
            startContentDetection();
        }

        // Also handle window load as additional fallback
        window.addEventListener('load', function() {
            if (!smwInitialized) {
                startContentDetection();
            }
        });
    })();
</script>

