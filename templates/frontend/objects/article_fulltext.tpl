{**
 * templates/frontend/objects/article_details.tpl
 *
 * Copyright (c) 2026 Simon Fraser University
 * Copyright (c) 2026 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
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
                    {assign var="doiUrl" value=$doiObject->getData('resolvingUrl')}
                    <a href="{$doiUrl|escape}" class="text-decoration-none">
                        {$doiUrl|escape}
                    </a>
                </dd>
             {/if}

            <dt>
                Cite this as:
            </dt>
            <dd>
                <span id="citestring">
					{$currentJournal->getLocalizedName()|escape}
					{if $issue->getYear()} {$issue->getYear()|escape}{/if}
					{if $issue->getVolume()}{if $issue->getYear()};{/if}{translate key="issue.vol"} {$issue->getVolume()|escape}{/if}
					{if $publication->getData('pages')}:{$publication->getData('pages')|escape}{/if}
				</span>
            </dd>
        </dl>
    </div><!-- .article-page__meta-->

    {* Hook for plugins under the main block, like Recommend Articles by Author *}
    {call_hook name="Templates::Article::Main"}

    <!-- sub-oh The content of the HTML file goes here -->
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

{*
    Image lightbox. Styles live in styles/articleFulltext.less and behaviour
    lives in js/articleFulltext.js — both registered by
    SmwImmersionChildThemePlugin::init().
*}
<div id="myModal" class="smw-image-modal">
    <div class="smw-image-modal__content">
        <span class="smw-image-modal__close" aria-label="{translate key="common.close"}">&times;</span>
        <div>
            <img id="modalImg" src="" alt="">
        </div>
    </div>
</div>

