{**
 * templates/frontend/pages/issueArchive.tpl
 *
 * Copyright (c) 2026 Simon Fraser University
 * Copyright (c) 2026 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Display a list of recent issues.
 *
 * @uses $issues Array Collection of issues to display
 * @uses $prevPage int The previous page number
 * @uses $nextPage int The next page number
 * @uses $showingStart int The number of the first item on this page
 * @uses $showingEnd int The number of the last item on this page
 * @uses $total int Count of all published monographs
 *}
{capture assign="pageTitle"}
    {if $prevPage}
        {translate key="archive.archivesPageNumber" pageNumber=$prevPage+1}
    {else}
        {translate key="archive.archives"}
    {/if}
{/capture}

{include file="frontend/components/header.tpl" pageTitleTranslated=$pageTitle}

<main class="container main__content" id="immersion_content_main">
    <header class="main__header">
        <h1 class="main__title">
            <span>{$pageTitle|escape}</span>
        </h1>
    </header>

    <div class="row">


        {* No issues have been published *}
        {if empty($issues)}
            <div class="col-sm">
                <p>{translate key="current.noCurrentIssueDesc"}</p>
            </div>

        {* List issues *}
        {else}
            <div style="margin-bottom:2rem;">
            {foreach from=$issues item="issue"}

                {if $issue->getYear() != $lastYear}
                <a class="article__btn pdf" style="margin-right:2px;margin-bottom:5px;width:72px;" href="#{$issue->getYear()|escape}">{$issue->getYear()|escape}</a>
                {assign var=lastYear value=$issue->getYear()}
                {/if}
            {/foreach}
            </div>
            {foreach from=$issues item="issue"}

                {if $issue->getYear() != $lastYear}
                <div style="width:100%;font-weight:500;font-size:1.5rem;padding-left:.85rem;margin-bottom:1rem;"><a id="{$issue->getYear()|escape}">Volume {$issue->getVolume()|escape} ({$issue->getYear()|escape}) <a class="article__btn pdf" style="margin-left:.5vw;padding:.25em .5em;font-size:.8rem;vertical-align:middle;" href="#">Go to Top</a> </div>
                {assign var=lastYear value=$issue->getYear()}
                {/if}
                <article class="col-md-3 col-lg-2 archived-issue">
                    {include file="frontend/objects/issue_summary.tpl"}
                </article>

            {/foreach}


            {* Pagination *}
            <div class="issue__pagination col-12">
                {if $prevPage > 1}
                    {capture assign=prevUrl}{url router=$smarty.const.ROUTE_PAGE page="issue" op="archive" path=$prevPage}{/capture}
                {elseif $prevPage === 1}
                    {capture assign=prevUrl}{url router=$smarty.const.ROUTE_PAGE page="issue" op="archive"}{/capture}
                {/if}
                {if $nextPage}
                    {capture assign=nextUrl}{url router=$smarty.const.ROUTE_PAGE page="issue" op="archive" path=$nextPage}{/capture}
                {/if}
                {include
                    file="frontend/components/pagination.tpl"
                    prevUrl=$prevUrl
                    nextUrl=$nextUrl
                    showingStart=$showingStart
                    showingEnd=$showingEnd
                    total=$total
                }
            </div>
        {/if}


    </div><!-- .row -->
</main>

{include file="frontend/components/footer.tpl"}

<style>
html {
  scroll-behavior: smooth;
  scroll-padding-top: 3rem;
}
</style>
