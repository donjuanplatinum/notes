# MCP
Emacs的MCP服务器

## 配置
注意 如果你的gptel配置了`:defer t` 那么你的mcp就不要配置`:after gptel` 否则你不打开gptel是无法初始化mcp的
```emacs-lisp
(use-package mcp
      :ensure t
      :defer t
      :custom (mcp-hub-servers
               `(("filesystem" . (:command "podman" 
      				     :args ("run"
      					    "-i"
      					    "--rm"
      					    "--mount" "type=bind,src=/home/donjuan/git,dst=/projects/git"
      					    "docker.io/mcp/filesystem"
      					    "/projects"
      				    )
                                  ))
  	       )
    	     )
      :config 
		  (require 'mcp-hub)
		  (require 'gptel-integrations)
	  
      :hook (after-init . mcp-hub-start-all-server))t
```

## Keyt
|||
