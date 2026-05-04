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
        {if $currentPublication->getId() !== $publication->getId()}
        <div class="article-page__alert" role="alert">
            {capture assign="latestVersionUrl"}{url page="article" op="view" path=$article->getBestId()}{/capture}
            {translate key="submission.outdatedVersion"
                datePublished=$publication->getData('datePublished')|date_format:$dateFormatShort
                urlRecentVersion=$latestVersionUrl|escape
            }
        </div>

        {/if}

        {assign var=doiObject value=$article->getCurrentPublication()->getData('doiObject')}
        {if $doiObject}
            {assign var="doiUrl" value=$doiObject->getData('resolvingUrl')}
            <dl>
                <dt>DOI:</dt>
                <dd>
                    <a href="{$doiUrl|escape}" class="text-decoration-none">{$doiUrl|escape}</a>
                </dd>
            </dl>
        {/if}

        {if $section}
            <p class="article-page__meta">{$section->getLocalizedTitle()|escape}</p>
        {else}
            <p class="article-page__meta">{translate key="article.article"}</p>
        {/if}

        <p class="article-page__meta">
            <a href="{url page="issue" op="view" path=$issue->getBestIssueId()}">{$issue->getIssueIdentification()|escape}</a>
        </p>

        <h1 class="article-page__title">
            <span>{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}</span>
        </h1>

        {* Article Subtitle *}
        {if $publication->getLocalizedData('subtitle')}
            <h2 class="article-page__subtitle">
                <span>{$publication->getLocalizedData('subtitle')|escape}</span>
            </h2>
        {/if}

        {* authors list *}
        {if $publication->getData('authors')}
            <div class="article-page__meta">
                <ul class="authors-string">
                    {foreach from=$publication->getData('authors') item=authorString key=authorStringKey}
                        {strip}
                            <li class="authors-string__item">
                                {capture}
                                    {if count($authorString->getAffiliations()) > 0 || $authorString->getLocalizedBiography()}
                                        {assign var=authorInfo value=true}
                                    {else}
                                        {assign var=authorInfo value=false}
                                    {/if}
                                {/capture}
                                {if $authorInfo}
                                    <a class="author-string__href" href="#author-{$authorStringKey+1}">
                                        <span>{$authorString->getFullName()|escape}</span>
                                        <sup class="author-symbol author-plus">&plus;</sup>
                                        <sup class="author-symbol author-minus hidden">&minus;</sup>
                                    </a>
                                    {else}
                                    <span class="author-string_href-none">
                                        <span>{$authorString->getFullName()|escape}</span>
                                    </span>
                                {/if}
                                {if $authorString->getData('orcid')}
                                    <a class="orcidImage img-wrapper" href="{$authorString->getData('orcid')|escape}">
                                        {if $authorString->hasVerifiedOrcid()}
                                            {$orcidIcon}
                                        {else}
                                            {$orcidUnauthenticatedIcon}
                                        {/if}
                                    </a>
                                {/if}
                            </li>
                        {/strip}
                    {/foreach}
                </ul>
            </div>
            {* Authors *}
            {assign var="authorCount" value=$publication->getData('authors')|@count}
            {assign var="authorBioIndex" value=0}
        {/if}
    </header>

    {* Article Galleys *}
    {if $primaryGalleys || $supplementaryGalleys}
        <div class="article-page__galleys">
            {if $primaryGalleys}
                <ul class="list-galleys primary-galleys">
                    {foreach from=$primaryGalleys item=galley}
                        <li>
                            {include file="frontend/objects/galley_link.tpl" parent=$article publication=$publication galley=$galley purchaseFee=$currentJournal->getData('purchaseArticleFee') purchaseCurrency=$currentJournal->getData('currency')}
                        </li>
                    {/foreach}
                </ul>
            {/if}
            {if $supplementaryGalleys}
                <ul class="list-galleys supplementary-galleys">
                    {foreach from=$supplementaryGalleys item=galley}
                        <li>
                            {include file="frontend/objects/galley_link.tpl" parent=$article publication=$publication galley=$galley isSupplementary="1"}
                        </li>
                    {/foreach}
                </ul>
            {/if}
        </div>
    {/if}

    <div class="article-page__meta">

        <dl>
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


            {if $publication->getData('datePublished')}
                <dt>
                    {translate key="submissions.published"}
                </dt>
                <dd>
                    {* If this is the original version *}
                    {if $firstPublication->getID() === $publication->getId()}
                        {$firstPublication->getData('datePublished')|date_format:$dateFormatShort}
                    {* If this is an updated version *}
                    {else}
                        {translate key="submission.updatedOn" datePublished=$firstPublication->getData('datePublished')|date_format:$dateFormatShort dateUpdated=$publication->getData('datePublished')|date_format:$dateFormatShort}
                    {/if}
                </dd>
                {if count($article->getPublishedPublications()) > 1}
                    <dt>
                        {translate key="submission.versions"}
                    </dt>
                    <dd>
                        <ul class="article-page__versions">
                            {foreach from=array_reverse($article->getPublishedPublications()) item=iPublication}
                                {capture assign="name"}{translate key="submission.versionIdentity" datePublished=$iPublication->getData('datePublished')|date_format:$dateFormatShort version=$iPublication->getData('version')}{/capture}
                                <li>
                                    {if $iPublication->getId() === $publication->getId()}
                                        {$name}
                                    {elseif $iPublication->getId() === $currentPublication->getId()}
                                        <a href="{url page="article" op="view" path=$article->getBestId()}">{$name}</a>
                                    {else}
                                        <a href="{url page="article" op="view" path=$article->getBestId()|to_array:"version":$iPublication->getId()}">{$name}</a>
                                    {/if}
                                </li>
                            {/foreach}
                        </ul>
                    </dd>
                {/if}
            {/if}

        </dl>
    </div><!-- .article-page__meta-->

    {* Abstract *}
    {if $publication->getLocalizedData('abstract')}
        <h3 class="label">{translate key="submission.summary"}</h3>
        {$publication->getLocalizedData('abstract')|strip_unsafe_html}
    {/if}

    {* References *}
    {if $parsedCitations || $publication->getData('citationsRaw')}
        <h3 class="label">
            {translate key="submission.citations"}
        </h3>
        {if $parsedCitations}
            <ol class="references">
                {foreach from=$parsedCitations item="parsedCitation"}
                    <li>{$parsedCitation->getCitationWithLinks()|strip_unsafe_html} {call_hook name="Templates::Article::Details::Reference" citation=$parsedCitation}</li>
                {/foreach}
            </ol>
        {else}
            <div class="references">
                {$publication->getData('citationsRaw')|escape|nl2br}
            </div>
        {/if}
    {/if}

    {* Hook for plugins under the main block, like Recommend Articles by Author *}
    {call_hook name="Templates::Article::Main"}

</section>


<aside class="col-md-4 offset-lg-1 col-lg-3 article-sidebar">
    {include file="frontend/components/article_sidebar.tpl"}
</aside>
