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
 * @uses $currentPublication Publication The most recently published version of this article
 * @uses $issue Issue The issue this article is assigned to
 * @uses $licenseTerms string License terms.
 * @uses $licenseUrl string URL to license. Only assigned if license should be
 *   included with published articles.
 * @uses $ccLicenseBadge string An image and text with details about the license
 *}

{* Article/Issue cover image *}
{if $publication->getLocalizedData('coverImage') || ($issue && $issue->getLocalizedCoverImage())}
    <h2 class="visually-hidden">{translate key="plugins.themes.immersion.article.figure"}</h2>
    <figure>
        {if $publication->getLocalizedData('coverImage')}
            <img
                class="img-fluid"
                src="{$publication->getLocalizedCoverImageUrl($article->getData('contextId'))|escape}"
                alt="{$coverImage.altText|escape|default:''}"
            >
            <div class="pictureCopyright">
                {$publication->getLocalizedData('coverImageAltText')|escape|default:''}
            </div>
        {else}
            <a href="{url page="issue" op="view" path=$issue->getBestIssueId()}">
                <img
                    class="img-fluid"
                    src="{$issue->getLocalizedCoverImageUrl()|escape}"
                    alt="{$issue->getLocalizedData('coverImageAltText')|escape|default:''}"
                >
            </a>
        {/if}
    </figure>
{/if}

{* Display other versions *}
{if $publication->getData('datePublished')}
    {if count($article->getPublishedPublications()) > 1}
        <h2 class="article-side__title">{translate key="submission.versions"}</h2>
        <ul>
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
    {/if}
{/if}

{* Keywords *}
{if !empty($publication->getLocalizedData('keywords'))}
<!--
    <h2 class="article-side__title">{translate key="article.subject"}</h2>
    <ul>
        {foreach name=keywords from=$publication->getLocalizedData('keywords') item=keyword}
            <li>{$keyword|escape}</li>
        {/foreach}
    </ul>
-->
{/if}

{* Display categories *}
{if $categories}
    <h2 class="article-side__title">{translate key="category.category"}</h2>
    <ul>
        {foreach from=$categories item=category}
            <li><a href="{url router=$smarty.const.ROUTE_PAGE page="catalog" op="category" path=$category->getPath()|escape}">{$category->getLocalizedTitle()|escape}</a></li>
        {/foreach}
    </ul>
{/if}

{call_hook name="Templates::Article::Details"}

{* Licensing info *}
{assign 'licenseTerms' $currentContext->getLocalizedData('licenseTerms')}
{assign 'copyrightHolder' $publication->getLocalizedData('copyrightHolder')}
{* overwriting deprecated variables *}
{assign 'licenseUrl' $publication->getData('licenseUrl')}
{assign 'copyrightYear' $publication->getData('copyrightYear')}

{if $licenseTerms || $licenseUrl}
    <div class="copyright-info">
        {if $licenseUrl}
            {if $ccLicenseBadge}
                {if $copyrightHolder}
                    <p>{translate key="submission.copyrightStatement" copyrightHolder=$copyrightHolder|escape copyrightYear=$copyrightYear|escape}</p>
                {/if}
                {$ccLicenseBadge}
            {else}
                <a href="{$licenseUrl|escape}" class="copyright">
                    {if $copyrightHolder}
                        {translate key="submission.copyrightStatement" copyrightHolder=$copyrightHolder|escape copyrightYear=$copyrightYear|escape}
                    {else}
                        {translate key="submission.license"}
                    {/if}
                </a>
            {/if}
        {/if}

        {* License terms modal. Show only if license is absent *}
        {if $licenseTerms && !$licenseUrl}
            <a class="copyright-notice__modal" data-bs-toggle="modal" data-bs-target="#copyrightModal">
                {translate key="about.copyrightNotice"}
            </a>

            <div
                class="modal fade"
                id="copyrightModal"
                tabindex="-1"
                role="dialog"
                aria-labelledby="copyrightModalTitle"
                aria-hidden="true"
            >
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="copyrightModalTitle">
                                {translate key="about.copyrightNotice"}
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            {$licenseTerms|strip_unsafe_html}
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-primary" data-bs-dismiss="modal">
                                {translate key="common.close"}
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        {/if}
    </div>
{/if}
