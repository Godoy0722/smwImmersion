{**
 * templates/frontend/pages/display.tpl
 *
 * Copyright (c) 2026 Simon Fraser University
 * Copyright (c) 2026 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Display the page to view an article with all of it's details.
 *
 * @uses $article Article This article
 * @uses $publication Publication The publication being displayed
 * @uses $firstPublication Publication The first published version of this article
 * @uses $currentPublication Publication The most recently published version of this article
 * @uses $issue Issue The issue this article is assigned to
 * @uses $section Section The journal section this article is assigned to
 * @uses $journal Journal The journal currently being viewed.
 * @uses $primaryGalleys array List of article galleys that are not supplementary or dependent
 * @uses $supplementaryGalleys array List of article galleys that are supplementary
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$article->getCurrentPublication()->getLocalizedFullTitle(null, 'html')|strip_unsafe_html}

<main class="container" id="immersion_content_main">
    <div class="row">

        {* Show article overview *}
        {include file="frontend/objects/article_fulltext.tpl"}

        {call_hook name="Templates::Article::Footer::PageFooter"}
    </div>
    <div class="row">
        <div class="main_entry">
        <!-- sub-oh The content of the HTML file goes here -->
        <div class="item" id="htmlContainer2" style="padding: 0;display:none;">
            <div style="padding: 30px;">
                <i class="fa fa-spinner fa-spin" style="font-size: 3em;"></i>
                <p>To see the page, Javascript must be enabled.</p>
                {assign var="articleId" value=$article->getBestId()}
                <p>Alternatively, you can download the <a href="{url page="article" op="download" path=$articleId|to_array:$galley->getBestGalleyId() inline=true}">raw html article</a></p>
            </div>
        </div>
    </div>
</main><!-- .page -->

{*
    Galley page wrapper. Styles live in styles/htmlGalley.less and the
    galley loader lives in js/htmlGalley.js — both registered by
    SmwImmersionChildThemePlugin::init(). The element below carries the
    galley download URL via a data attribute (escaped by Smarty), avoiding
    inline JavaScript entirely.
*}
<div
	id="smwGalleyConfig"
	hidden
    data-url="{url page="article" op="download" path=$articleId|to_array:$galley->getBestGalleyId() inline=true}"
></div>

{include file="frontend/components/footer.tpl"}
