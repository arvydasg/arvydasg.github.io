;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
;; (unless package-archive-contents
;; (package-refresh-contents))
(package-refresh-contents)

;; ;; Install dependencies
(package-install 'htmlize)
(package-install 'org)
(package-install 'org-roam)

;; Load the publishing system
(require 'ox-publish)
(require 'org-roam)

(setq org-roam-directory (file-truename "~/Dropbox/documents/org/roam/personal/blog"))
(setq org-id-link-to-org-use-id t)
;; (org-roam-db-autosync-mode)

;;; CODE:

(setq org-publish-project-alist
      '(("org"
         :base-directory "~/Dropbox/documents/org/roam/personal/blog"
         :base-extension "org"
         ;; :exclude "20220504180110-pkc.org"
         :publishing-directory "~/Dropbox/src/arvydasg.github.io"
         :publishing-function org-html-publish-to-html
         :recursive t
         :with-author nil           ;; Don't include author name
         :with-creator t            ;; Include Emacs and Org versions in footer
         :with-toc t                ;; Include a table of contents
         :with-title nil
         ;; :section-numbers 2       ;; include only first two section numbers
         :section-numbers nil       ;; Don't include section numbers
         :time-stamp-file nil
         
         ;; sitemap stuff
         :auto-sitemap t
         :sitemap-sort-files anti-chronologically
         
         ;; head, nav, footer
         :html-head "<link rel=\"stylesheet\" href=\"./css/style.css\"/>"
         :html-preamble
         "<nav class='navbar'>
          <!-- LOGO -->
            <a class='logo' href='sitemap.html'>Arvydasg</a>
            <!-- NAVIGATION MENU -->
            <ul class='nav-links'>
                <!-- USING CHECKBOX HACK -->
                <input type='checkbox' id='checkbox_toggle' />
                <label for='checkbox_toggle' class='hamburger'>&#9776;</label>
                <!-- NAVIGATION MENUS -->
                <div class='menu'>
                    <li><a href='20220621220229-ossu.html'>Ossu</a></li>
                    <li><a href='20220619101553-blog.html'>Blog</a></li>
                    <li><a href='20220619101641-blog_projects.html'>Projects</a></li>
                </div>
            </ul>
         </nav>"
         :html-postamble
         "<div class='footer'>
             <hr>
             Last updated %C. <br>
             Arvydas.<br>
             Built with %c.
         </div>")

        ("static"
         :base-directory "~/Dropbox/documents/org/images_nejudink"
         :base-extension "jpg\\|gif\\|png\\|pdf\\|xlsx\\|txt"
         :publishing-directory "~/Dropbox/src/arvydasg.github.io/static"
         :publishing-function org-publish-attachment
         :recursive t)
        ("css"
         :base-directory "./css"
         :base-extension "css"
         :publishing-directory "~/Dropbox/src/arvydasg.github.io/css"
         :publishing-function org-publish-attachment
         :recursive t)
        ("all" :components ("org" "static" "css"))))

(setq org-export-with-broken-links 'mark)

;; --------------------------------------------------------------------------------
;; Stuff below converts roam links to html links on export
;; https://www.reddit.com/r/emacs/comments/q82zci/how_to_include_the_id_links_into_your_orgroam/

(setq org-id-extra-files (org-roam-list-files))

(defun org-html--reference (datum info &optional named-only)
  "Return an appropriate reference for DATUM.
DATUM is an element or a `target' type object.  INFO is the
current export state, as a plist.
When NAMED-ONLY is non-nil and DATUM has no NAME keyword, return
nil.  This doesn't apply to headlines, inline tasks, radio
targets and targets."
  (let* ((type (org-element-type datum))
	 (user-label
	  (org-element-property
	   (pcase type
	     ((or `headline `inlinetask) :CUSTOM_ID)
	     ((or `radio-target `target) :value)
	     (_ :name))
	   datum))
         (user-label (or user-label
                         (when-let ((path (org-element-property :ID datum)))
                           (concat "ID-" path)))))
    (cond
     ((and user-label
	   (or (plist-get info :html-prefer-user-labels)
	       ;; Used CUSTOM_ID property unconditionally.
	       (memq type '(headline inlinetask))))
      user-label)
     ((and named-only
	   (not (memq type '(headline inlinetask radio-target target)))
	   (not user-label))
      nil)
     (t
      (org-export-get-reference datum info)))))

;; --------------------------------------------------------------------------------

;; Generate the site output
(org-publish-all t)

(message "Build complete!")

;;; Build-site.el ends here
