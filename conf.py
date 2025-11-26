# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Donjuanplatinum Notes'
copyright = '2025, Donjuanplatinum'
author = 'Donjuanplatinum'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'myst_parser', 
    'sphinx.ext.mathjax',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

language = 'zh_CN'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']



html_logo = "resource/profile.png"
html_favicon = "resource/profile.png"

html_theme_options = {
    "collapse_navigation": False,
    "navigation_depth": 400,
}

source_suffix = ['.rst', '.md']
myst_enable_extensions = [
    "amsmath",    # 支持 \begin{equation} 等环境
    "dollarmath", # 支持 $...$ 和 $$...$$
    "sphinx_copybutton",
    "sphinxcontrib_images",
]
mathjax_path = "MathJax.js"

