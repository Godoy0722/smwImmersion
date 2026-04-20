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

use PKP\plugins\ThemePlugin;
use PKP\plugins\Hook;

class SmwImmersionChildThemePlugin extends ThemePlugin {

    /**
     * @copydoc \PKP\plugins\ThemePlugin::init()
     */
    public function init()
    {
        $this->setParent('immersionthemeplugin');

        $this->addStyle('child-stylesheet', 'styles/index.less');

        Hook::add('TemplateManager::display', [$this, 'addSearchTemplateData']);
        Hook::add('ArticleHandler::view::galley', [$this, 'triggerArticleViewHook'], Hook::SEQUENCE_CORE);
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
