{**
 * templates/frontend/components/footer.tpl
 *
 * Copyright (c) 2026 Simon Fraser University
 * Copyright (c) 2026 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Common site frontend footer.
 *
 * @uses $isFullWidth bool Should this page be displayed without sidebars? This
 *       represents a page-level override, and doesn't indicate whether or not
 *       sidebars have been configured for the site.
 *}

<footer class="main-footer" id="immersion_content_footer">
    <div class="container">
        {if $hasSidebar}
            <div class="sidebar_wrapper row" role="complementary">
                {call_hook name="Templates::Common::Sidebar"}
            </div>
            <hr>
        {/if}
        <div class="row">
            {if $pageFooter}
                <div class="col-md-8">
                    {$pageFooter}
                </div>
            {/if}
            <div class="col-2 col-sm-4 text-end" role="complementary">
                <a href="{url page="about" op="aboutThisPublishingSystem"}">
                    <img style="width:60px;padding-top:20px;" class="img-fluid" alt="{translate key="about.aboutThisPublishingSystem"}" src="{$baseUrl}/{$brandImage}">
                </a>
            </div>
        </div>
    </div>
</footer>

{* Login modal *}
{if $requestedOp != "register"}
    <div id="loginModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    {include file="frontend/components/loginForm.tpl" formType = "loginModal"}
                </div>
            </div>
        </div>
    </div>
{/if}

{load_script context="frontend"}

{call_hook name="Templates::Common::Footer::PageFooter"}


</body>
</html>
