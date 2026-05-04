<?php

/**
 * @file plugins/themes/smwImmersion/SmwImmersionChildThemePlugin.php
 *
 * Copyright (c) 2026 Simon Fraser University
 * Copyright (c) 2026 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class SmwImmersionChildThemePlugin
 * @ingroup plugins_themes_smwImmersion
 *
 * @brief SmwImmersion theme
 */

namespace APP\plugins\themes\smwImmersion;

use APP\core\Application;
use APP\notification\NotificationManager;
use PKP\notification\Notification;
use PKP\plugins\Hook;
use PKP\plugins\PluginRegistry;
use PKP\plugins\ThemePlugin;

class SmwImmersionChildThemePlugin extends ThemePlugin {

    /** Plugin registry key of the required parent theme. */
    private const PARENT_THEME_KEY = 'immersionthemeplugin';

    /**
     * @copydoc \PKP\plugins\ThemePlugin::init()
     */
    public function init()
    {
        // SMW Immersion is a child of the Immersion theme. Without that parent
        // installed the styles, templates and options it inherits are missing,
        // so refuse to register anything and surface a notice to admins.
        if (!$this->isParentThemeAvailable()) {
            $this->registerMissingParentNotice();
            return;
        }

        $this->setParent(self::PARENT_THEME_KEY);

        $this->addStyle('child-stylesheet', 'styles/index.less');

        $this->addScript('smwArticleDetails', 'js/articleDetails.js', ['contexts' => 'frontend']);
        $this->addScript('smwArticleFulltext', 'js/articleFulltext.js', ['contexts' => 'frontend']);
        $this->addScript('smwHtmlGalley', 'js/htmlGalley.js', ['contexts' => 'frontend']);

        Hook::add('TemplateManager::display', [$this, 'addSearchTemplateData']);
        Hook::add('ArticleHandler::view::galley', [$this, 'triggerArticleViewHook'], Hook::SEQUENCE_CORE);
    }

    /**
     * Check whether the Immersion parent theme is installed and registered.
     */
    private function isParentThemeAvailable(): bool
    {
        return PluginRegistry::getPlugin('themes', self::PARENT_THEME_KEY) instanceof ThemePlugin;
    }

    /**
     * Flash a warning on the website settings page when an admin lands there
     * without the required parent theme installed.
     */
    private function registerMissingParentNotice(): void
    {
        Hook::add('TemplateManager::display', function ($hookName, $args) {
            $template = $args[1] ?? null;
            if ($template !== 'management/website.tpl') {
                return false;
            }

            $user = Application::get()->getRequest()->getUser();
            if (!$user) {
                return false;
            }

            $notificationMgr = new NotificationManager();
            $notificationMgr->createTrivialNotification(
                $user->getId(),
                Notification::NOTIFICATION_TYPE_WARNING,
                ['contents' => __('plugins.themes.smwimmersion.parentMissing')]
            );

            return false;
        });
    }

    /**
     * Assign the abstractsOnIssuePage theme option to the search page
     * so article summaries can display with the fade-out effect.
     */
    public function addSearchTemplateData($hookName, $args)
    {
        $templateMgr = $args[0];
        $template = $args[1];

        if ($template !== 'frontend/pages/search.tpl') return false;

        $templateMgr->assign([
            'showAbstractsOnIssuePage' => $this->getOption('abstractsOnIssuePage'),
        ]);

        return false;
    }

    /**
     * Trigger the ArticleHandler::view hook before HTML galley rendering
     * This ensures plugins that listen to ArticleHandler::view can prepare data
     * for template hooks that are called in the galley view templates
     *
     * @param string $hookName
     * @param array $args [request, issue, galley, article, publication]
     * @return bool
     */
    public function triggerArticleViewHook($hookName, $args)
    {
        $request = $args[0];
        $issue = $args[1];
        $galley = $args[2];
        $article = $args[3];
        $publication = $args[4] ?? $article->getCurrentPublication();

        if ($galley && $galley->getFileType() === 'text/html') {
            Hook::call('ArticleHandler::view', [&$request, &$issue, &$article, $publication]);
        }

        return false;
    }


    /**
     * @copydoc \PKP\plugins\ThemePlugin::getDisplayName()
     */
    public function getDisplayName() {
        return __('plugins.themes.smwimmersion.name');
    }

    /**
     * @copydoc \PKP\plugins\ThemePlugin::getDescription()
     */
    public function getDescription() {
        return __('plugins.themes.smwimmersion.description');
    }
}
