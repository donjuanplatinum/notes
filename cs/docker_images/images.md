# 容器镜像配置

<a id="orgff9efbc"></a>

## openwrt


<a id="org2ce31f9"></a>

### compose

    version: '3'
    
    services:
      openwrt:
        image: sulinggg/openwrt:x86_64
        privileged: true
        restart: always
        networks:
          openwrt:
           ipv4_address: 192.168.101.39
        volumes:
          - ./network.conf:/etc/config/network
          - ./var:/var
        command: /sbin/init
    networks:
      openwrt:
       external: true


<a id="orga3ca7cf"></a>

### 网卡

    ip link set enp3s0 promisc on
    docker network create -d macvlan --subnet=192.168.22.1/24 --gateway=192.168.22.1 -o parent=enp3s0 wrtnet


<a id="orgc45d0b6"></a>

## Pandoc

    docker run --rm -v "./data:/data" --user `id -u`:`id -g` pandoc/latex README.md -o README.pdf


<a id="org33bb0da"></a>

## certbot

dns txt记录认证

    certbot certonly --preferred-challenges dns -d "*.donjuan.lecturify.net" --manual

    sudo docker run -v ./letsencrypt:/etc/letsencrypt --rm  -it docker.nju.edu.cn/certbot/certbot  certonly --preferred-challenges dns -d "*.donjuan.lecturify.net" --manual  


<a id="org3aeef62"></a>

## matrix conduit

[gitlab<sub>conduit</sub>](https://gitlab.com/famedly/conduit)


<a id="orgb7f9778"></a>

### conduit

1.  docker-compose

        version: '3'
        
        services:
          homeserver:
            container_name: conduit
            image: docker.nju.edu.cn/matrixconduit/matrix-conduit:latest
            #    network_mode: host
            networks:
              conduit:
            ports:
              - 8008:8008
            volumes:
              - ./data:/data
            environment:
                CONDUIT_SERVER_NAME: matrix.donjuan.lecturify.net # EDIT THIS
                CONDUIT_DATABASE_PATH: /data
                CONDUIT_DATABASE_BACKEND: rocksdb
                CONDUIT_PORT: 8008
                CONDUIT_MAX_REQUEST_SIZE: 20_000_000_0 # in bytes, ~200 MB
                CONDUIT_ALLOW_REGISTRATION: 'true'
                CONDUIT_ALLOW_FEDERATION: 'true'
                CONDUIT_ALLOW_CHECK_FOR_UPDATES: 'true'
                CONDUIT_TRUSTED_SERVERS: '["mozilla.org"]'
                #CONDUIT_MAX_CONCURRENT_REQUESTS: 100
                #CONDUIT_LOG: warn,rocket=off,_=off,sled=off
                CONDUIT_ADDRESS: 0.0.0.0
                CONDUIT_CONFIG: '' # Ignore this
                CONDUIT_TURN_URIS: '["turn:matrix.donjuan.lecturify.net:5349?transport=udp", "turn:matrix.donjuan.lecturify.net:5349?transport=tcp"]'
                CONDUIT_TURN_SECRET: "conduit6666"
        
          coturn:
            container_name: coturn
            image: docker.nju.edu.cn/coturn/coturn
            network_mode: host
            volumes:
              - ./coturn.conf:/etc/coturn/turnserver.conf
              - ../letsencrypt/live/donjuan.lecturify.net/fullchain.pem:/etc/ssl/certs/cert.pem:ro
              - ../letsencrypt/live/donjuan.lecturify.net/privkey.pem:/etc/ssl/private/privkey.pem:ro
          heisenbridge:
            container_name: heisenbridge
            image: docker.nju.edu.cn/hif1/heisenbridge
            command: "-c /data/config http://conduit:8008"
            networks:
              conduit:
            volumes:
              - ./heisenbridge_data:/data
          element-web:
            container_name: element
            image: docker.io/vectorim/element-web
            volumes:
              - ./element_config:/app/config.json
            ports:
              - 8777:80
          sysdent:
            container_name: sysdent
            image: docker.nju.edu.cn/matrixdotorg/sydent
            volumes:
              - ./sysdentdata:/data
            network_mode: host
          telegram:
           container_name: telegram
           shm_size: 64mb
           image: dock.mau.dev/mautrix/telegram
           volumes:
             - ./telegram:/data
           networks:
             - conduit
             - postgres
          email:
           container_name: matrix_mail
           shm_size: 64mb
           image: jojii/matrix_email_bridge
           volumes:
            - ./mail:/app/data
           networks:
            conduit:
        
        networks:
          conduit:
          postgres:
           external: true


<a id="orgba43a93"></a>

### heisenbridge

1.  生成heisenbridge<sub>data</sub>/config

        docker run  --rm -v ./heisenbridge_data:/data docker.nju.edu.cn/hif1/heisenbridge -l heisenbridge  --generate-compat -c /data/config http://conduit:8008


<a id="org1490139"></a>

### coturn

1.  coturn.conf

        use-auth-secret
        static-auth-secret=your secret
        realm=matrix.donjuan.lecturify.net


<a id="org38f3561"></a>

### element-web

      {
        "default_server_config": {
            "m.homeserver": {
                "base_url": "https://www.donjuan.lecturify.net:8448",
                "server_name": "donjuanplatinum"
            },
            "m.identity_server": {
                "base_url": "https://www.donjuan.lecturify.net:8901"
            }
        },
        "disable_custom_urls": false,
        "disable_guests": false,
        "disable_login_language_selector": false,
        "disable_3pid_login": false,
        "brand": "Element",
        "integrations_ui_url": "https://scalar.vector.im/",
        "integrations_rest_url": "https://scalar.vector.im/api",
        "integrations_widgets_urls": [
            "https://scalar.vector.im/_matrix/integrations/v1",
            "https://scalar.vector.im/api",
            "https://scalar-staging.vector.im/_matrix/integrations/v1",
            "https://scalar-staging.vector.im/api",
            "https://scalar-staging.riot.im/scalar/api"
        ],
        "default_country_code": "GB",
        "show_labs_settings": false,
        "features": {},
        "default_federate": true,
        "default_theme": "dark",
        "room_directory": {
            "servers": ["mozilla.org","poa.st"]
        },
        "enable_presence_by_hs_url": {
            "https://matrix.org": false,
            "https://matrix-client.matrix.org": false
        },
        "setting_defaults": {
            "breadcrumbs": true
        },
        "jitsi": {
            "preferred_domain": "meet.element.io"
        },
        "element_call": {
            "url": "https://call.element.io",
            "participant_limit": 8,
            "brand": "Element Call"
        },
        "map_style_url": "https://api.maptiler.com/maps/streets/style.json?key=fU3vlMsMn4Jb6dnEIFsx"
    }


<a id="org829cfc7"></a>

### mautrix-telegram


<a id="org3d2ae65"></a>

### mail

      {
      "allowed_servers": [
        "matrix.donjuan.lecturify.net"
      ],
      "defaultmailcheckinterval": 30,
      "htmldefault": false,
      "markdownenabledbydefault": true,
      "matrixaccesstoken": "",
      "matrixserver": "http://conduit:8008",
      "matrixuserid": "@mail:matrix.donjuan.lecturify.net"
    }

1.  生成样例配置文件
    
        docker run --rm -v ./telegram:/data dock.mau.dev/mautrix/telegram
2.  编辑
3.  生成registry文件
4.  @telegrambot:


<a id="orgb659af2"></a>

### matrix-qq

1.  compose

    compose
    
        version: "3"
        
        services:
         matrix-qq:
            hostname: matrix-qq
            container_name: matrix-qq
            image: docker.nju.edu.cn/lxduo/matrix-qq:latest
            restart: unless-stopped
            volumes:
              - ./matrix-qq:/data
            networks:
              - postgresql_psql
              - conduit_conduit
            ports:
              - 17777:17777
        
        networks:
         postgresql_psql:
          external: true
         conduit_conduit:
          external: true
    
    1.  修改config.yaml
    2.  config

2.  matrix-qq/config.yaml

          # Homeserver details.
        homeserver:
            # The address that this appservice can use to connect to the homeserver.
            address: http://homeserver:8008
            # The domain of the homeserver (for MXIDs, etc).
            domain: matrix.donjuan.lecturify.net
            # Set to null to disable using the websocket. When not using the websocket, make sure hostname and port are set in the appservice section.
            websocket_proxy:
            # How often should the websocket be pinged? Pinging will be disabled if this is zero.
            ping_interval_seconds: 0
            # What software is the homeserver running?
            # Standard Matrix homeservers like Synapse, Dendrite and Conduit should just use "standard" here.
            software: standard
            # The URL to push real-time bridge status to.
            # If set, the bridge will make POST requests to this URL whenever a user's connection state changes.
            # The bridge will use the appservice as_token to authorize requests.
            status_endpoint: null
            # Endpoint for reporting per-message status.
            message_send_checkpoint_endpoint: null
            # Does the homeserver support https://github.com/matrix-org/matrix-spec-proposals/pull/2246?
            async_media: false
        
        # Application service host/registration related details.
        # Changing these values requires regeneration of the registration.
        appservice:
            # The address that the homeserver can use to connect to this appservice.
            address: http://matrix-qq:17777
        
            # The hostname and port where this appservice should listen.
            hostname: 0.0.0.0
            port: 17777
        
            # Database config.
            database:
                # The database type. "sqlite3" and "postgres" are supported.
                type: postgres
                # The database URI.
                #   SQLite: File name is enough. https://github.com/mattn/go-sqlite3#connection-string
                #   Postgres: Connection string. For example, postgres://user:password@host/database?sslmode=disable
                #             To connect via Unix socket, use something like postgres:///dbname?host=/var/run/postgresql
                uri: postgres://postgres:postgresspassword@postgres/matrixqq?sslmode=disable
                # Maximum number of connections. Mostly relevant for Postgres.
                max_open_conns: 20
                max_idle_conns: 2
                # Maximum connection idle time and lifetime before they're closed. Disabled if null.
                # Parsed with https://pkg.go.dev/time#ParseDuration
                max_conn_idle_time: null
                max_conn_lifetime: null
        
            # The unique ID of this appservice.
            id: qq
            # Appservice bot details.
            bot:
                # Username of the appservice bot.
                username: qqbot
                # Display name and avatar for bot. Set to "remove" to remove display name/avatar, leave empty
                # to leave display name/avatar as-is.
                displayname: QQ bridge bot
                avatar: mxc://avatar url
            # Whether or not to receive ephemeral events via appservice transactions.
            # Requires MSC2409 support (i.e. Synapse 1.22+).
            # You should disable bridge -> sync_with_custom_puppets when this is enabled.
            ephemeral_events: true
        
            # Authentication tokens for AS <-> HS communication. Autogenerated; do not modify.
            as_token: "token"
            hs_token: "token"
        # QQ config
        qq:
            # QQ client protocol (1: AndroidPhone, 2: AndroidWatch, 3: MacOS, 4: QiDian, 5: IPad, 6: AndroidPad)
            protocol: 2
            # Sign Server (https://github.com/fuqiuluo/unidbg-fetch-qsign)
            sign_server: "http://192.168.101.75:8901"
        
        # Bridge config
        bridge:
            # Proxy for homeserver connection.
            hs_proxy:
            # Localpart template of MXIDs for QQ users.
            username_template: _qq_{{.}}
            # Displayname template for QQ users.
            displayname_template: "{{if .Name}}{{.Name}}{{else}}{{.Uin}}{{end}} (QQ)"
            # Should the bridge create a space for each logged-in user and add bridged rooms to it?
            # Users who logged in before turning this on should run `!wa sync space` to create and fill the space for the first time.
            personal_filtering_spaces: true
            # Whether the bridge should send the message status as a custom com.beeper.message_send_status event.
            message_status_events: false
            # Whether the bridge should send error notices via m.notice events when a message fails to bridge.
            message_error_notices: true
            portal_message_buffer: 128
            # Enable redaction
            allow_redaction: false
            # Should puppet avatars be fetched from the server even if an avatar is already set?
            user_avatar_sync: true
            # Should the bridge sync with double puppeting to receive EDUs that aren't normally sent to appservices.
            sync_with_custom_puppets: false
            # Should the bridge update the m.direct account data event when double puppeting is enabled.
            # Note that updating the m.direct event is not atomic (except with mautrix-asmux)
            # and is therefore prone to race conditions.
            sync_direct_chat_list: false
            # When double puppeting is enabled, users can use `!wa toggle` to change whether
            # presence is bridged. These settings set the default values.
            # Existing users won't be affected when these are changed.
            default_bridge_presence: false
            # Send the presence as "available" to QQ when users start typing on a portal.
            # This works as a workaround for homeservers that do not support presence, and allows
            # users to see when the qq user on the other side is typing during a conversation.
            send_presence_on_typing: true
            # Servers to always allow double puppeting from
            double_puppet_server_map:
                matrix.donjuan.lecturify.net: https://matrix.donjuan.lecturify.net:8448
            # Allow using double puppeting from any server with a valid client .well-known file.
            double_puppet_allow_discovery: false
            # Shared secrets for https://github.com/devture/matrix-synapse-shared-secret-auth
            #
            # If set, double puppeting will be enabled automatically for local users
            # instead of users having to find an access token and run `login-matrix`
            # manually.
            login_shared_secret_map:
                example.com: foobar
            # Should the bridge explicitly set the avatar and room name for private chat portal rooms?
            private_chat_portal_meta: false
            # Should group members be synced in parallel? This makes member sync faster
            parallel_member_sync: false
            # Set this to true to tell the bridge to re-send m.bridge events to all rooms on the next run.
            # This field will automatically be changed back to false after it, except if the config file is not writable.
            resend_bridge_info: false
            # When using double puppeting, should muted chats be muted in Matrix?
            mute_bridging: false
            # Allow invite permission for user. User can invite any bots to room with qq
            # users (private chat and groups)
            allow_user_invite: false
            # Whether or not created rooms should have federation enabled.
            # If false, created portal rooms will never be federated.
            federate_rooms: true
            # Should the bridge never send alerts to the bridge management room?
            # These are mostly things like the user being logged out.
            disable_bridge_alerts: false
            # Maximum time for handling Matrix events. Duration strings formatted for https://pkg.go.dev/time#ParseDuration
            # Null means there's no enforced timeout.
            message_handling_timeout:
                # Send an error message after this timeout, but keep waiting for the response until the deadline.
                # This is counted from the origin_server_ts, so the warning time is consistent regardless of the source of delay.
                # If the message is older than this when it reaches the bridge, the message won't be handled at all.
                error_after: null
                # Drop messages after this timeout. They may still go through if the message got sent to the servers.
                # This is counted from the time the bridge starts handling the message.
                deadline: 120s
        
            # The prefix for commands. Only required in non-management rooms.
            command_prefix: "!qq"
        
            # Messages sent upon joining a management room.
            # Markdown is supported. The defaults are listed below.
            management_room_text:
                # Sent when joining a room.
                welcome: "Hello, I'm a QQ bridge bot."
                # Sent when joining a management room and the user is already logged in.
                welcome_connected: "Use `help` for help."
                # Sent when joining a management room and the user is not logged in.
                welcome_unconnected: "Use `help` for help or `login` to log in."
                # Optional extra text sent when joining a management room.
                additional_help: ""
        
            # End-to-bridge encryption support options.
            #
            # See https://docs.mau.fi/bridges/general/end-to-bridge-encryption.html for more info.
            encryption:
                # Allow encryption, work in group chat rooms with e2ee enabled
                allow: true
                # Default to encryption, force-enable encryption in all portals the bridge creates
                # This will cause the bridge bot to be in private chats for the encryption to work properly.
                # It is recommended to also set private_chat_portal_meta to true when using this.
                default: false
                # Whether to use MSC2409/MSC3202 instead of /sync long polling for receiving encryption-related data.
                appservice: false
                # Require encryption, drop any unencrypted messages.
                require: false
                # Enable key sharing? If enabled, key requests for rooms where users are in will be fulfilled.
                # You must use a client that supports requesting keys from other users to use this feature.
                allow_key_sharing: false
                # What level of device verification should be required from users?
                #
                # Valid levels:
                #   unverified - Send keys to all device in the room.
                #   cross-signed-untrusted - Require valid cross-signing, but trust all cross-signing keys.
                #   cross-signed-tofu - Require valid cross-signing, trust cross-signing keys on first use (and reject changes).
                #   cross-signed-verified - Require valid cross-signing, plus a valid user signature from the bridge bot.
                #                           Note that creating user signatures from the bridge bot is not currently possible.
                #   verified - Require manual per-device verification
                #              (currently only possible by modifying the `trust` column in the `crypto_device` database table).
                verification_levels:
                    # Minimum level for which the bridge should send keys to when bridging messages from QQ to Matrix.
                    receive: unverified
                    # Minimum level that the bridge should accept for incoming Matrix messages.
                    send: unverified
                    # Minimum level that the bridge should require for accepting key requests.
                    share: cross-signed-tofu
                # Options for Megolm room key rotation. These options allow you to
                # configure the m.room.encryption event content. See:
                # https://spec.matrix.org/v1.3/client-server-api/#mroomencryption for
                # more information about that event.
                rotation:
                    # Enable custom Megolm room key rotation settings. Note that these
                    # settings will only apply to rooms created after this option is
                    # set.
                    enable_custom: false
                    # The maximum number of milliseconds a session should be used
                    # before changing it. The Matrix spec recommends 604800000 (a week)
                    # as the default.
                    milliseconds: 604800000
                    # The maximum number of messages that should be sent with a given a
                    # session before changing it. The Matrix spec recommends 100 as the
                    # default.
                    messages: 100
        
            # Permissions for using the bridge.
            # Permitted values:
            #     user - Access to use the bridge to chat with a QQ account.
            #    admin - User level and some additional administration tools
            # Permitted keys:
            #        * - All Matrix users
            #   domain - All users on that homeserver
            #     mxid - Specific user
            permissions:
                "matrix.donjuan.lecturify.net": admin
                "@donjuan:matrix.donjuan.lecturify.net": admin
        
        # Logging config.
        logging:
            # The directory for log files. Will be created if not found.
            directory: ./logs
            # Available variables: .Date for the file date and .Index for different log files on the same day.
            # Set this to null to disable logging to file.
            file_name_format: "{{.Date}}-{{.Index}}.log"
            # Date format for file names in the Go time format: https://golang.org/pkg/time/#pkg-constants
            file_date_format: "2006-01-02"
            # Log file permissions.
            file_mode: 0o600
            # Timestamp format for log entries in the Go time format.
            timestamp_format: "Jan _2, 2006 15:04:05"
            # Minimum severity for log messages printed to stdout/stderr. This doesn't affect the log file.
            # Options: debug, info, warn, error, fatal
            print_level: debug

3.  regis

    生成register.yaml
    
        docker run --rm -v `pwd`/matrix-qq:/data:z lxduo/matrix-qq:latest
    
    生成后appservice注册homeserver   

4.  unidbg

    1.  compose
    
            version: '2'
            
            services:
              qsign:
                image: ghcr.nju.edu.cn/fuqiuluo/unidbg-fetch-qsign
                environment:
                  TZ: Asia/Shanghai
                restart: always
                ports:
                  # 按需调整端口映射
                  - 8901:8080


<a id="orgc502c46"></a>

## blessing-skin


<a id="orgd4ec2da"></a>

### .env

      APP_DEBUG=false
    APP_ENV=production
    APP_FALLBACK_LOCALE=en
    
    DB_CONNECTION=sqlite
    DB_HOST=localhost
    DB_PORT=3306
    DB_DATABASE=/app/database.db
    DB_USERNAME=username
    DB_PASSWORD=secret
    DB_PREFIX=
    
    # Hash Algorithm for Passwords
    #
    # Available values:
    # - BCRYPT, ARGON2I, PHP_PASSWORD_HASH
    # - MD5, SALTED2MD5
    # - SHA256, SALTED2SHA256
    # - SHA512, SALTED2SHA512
    #
    # New sites are *highly* recommended to use BCRYPT.
    #
    PWD_METHOD=BCRYPT
    APP_KEY=base64:5RbZBYJGqz3EOOuJNyahHydzqFLRk1Od+Sak6HBvs6o=
    
    MAIL_MAILER=smtp
    MAIL_HOST=
    MAIL_PORT=465
    MAIL_USERNAME=
    MAIL_PASSWORD=
    MAIL_ENCRYPTION=
    MAIL_FROM_ADDRESS=
    MAIL_FROM_NAME=
    
    CACHE_DRIVER=file
    SESSION_DRIVER=file
    QUEUE_CONNECTION=sync
    
    REDIS_CLIENT=phpredis
    REDIS_HOST=127.0.0.1
    REDIS_PASSWORD=null
    REDIS_PORT=6379
    
    PLUGINS_DIR=/app/plugins
    PLUGINS_URL=null


<a id="orgf6b9e19"></a>

### docker-compose.yml

      version: '3'
    
    services:
      skin:
        container_name: bs
        image: docker.nju.edu.cn/donjuanplatinum/blessing-skin-server
        network_mode: host
        volumes:
          - ./app:/app
          - ./storage:/app/storage
        environment:
          - DB_DATABASE=/app/database.db
          - PLUGINS_DIR=/app/plugins


<a id="org17a26fc"></a>

## trojan


<a id="orgbe23624"></a>

### docker-compose

    version: '3'
    services:
      trojan:
        container_name: trojan
        image: trojangfw/trojan
        network_mode: host
        volumes:
          - ./config.json:/config/config.json
          - ../letsencrypt/live/donjuan.lecturify.net:/etc/certs


<a id="org075124d"></a>

### config.json

      {
        "run_type": "server",
        "local_addr": "0.0.0.0",
        "local_port": 443,
        "remote_addr": "127.0.0.1",
        "remote_port": 8777,
        "password": [
            "password1",
            "password2"
        ],
        "log_level": 1,
        "ssl": {
            "cert": "/etc/certs/fullchain.pem",
            "key": "/etc/certs/privkey.pem",
            "key_password": "",
            "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384",
            "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
            "prefer_server_cipher": true,
            "alpn": [
                "http/1.1"
            ],
            "alpn_port_override": {
                "h2": 81
            },
            "reuse_session": true,
            "session_ticket": false,
            "session_timeout": 600,
            "plain_http_response": "",
            "curves": "",
            "dhparam": ""
        },
        "tcp": {
            "prefer_ipv4": false,
            "no_delay": true,
            "keep_alive": true,
            "reuse_port": false,
            "fast_open": false,
            "fast_open_qlen": 20
        },
        "mysql": {
            "enabled": false,
            "server_addr": "127.0.0.1",
            "server_port": 3306,
            "database": "trojan",
            "username": "trojan",
            "password": "",
            "key": "",
            "cert": "",
            "ca": ""
        }
    }


<a id="orgffa283e"></a>

### 注意!

在cloudflare下的ssl/tls ssl/tls加密设置为完全 严格


<a id="org9795cd1"></a>

## gitea


<a id="org22bccd9"></a>

### docker-compose

    version: '3'
    
    services:
      gitea:
        container_name: gitea
        image: docker.nju.edu.cn/gitea/gitea
        #    network_mode: host
        networks:
            postgres:
        ports:
            - 3000:3000
            - 2222:2222
        volumes:
            - ./data:/data
            - ./config:/etc/gitea
            - /etc/timezone:/etc/timezone:ro
            - /etc/localtime:/etc/localtime:ro
    
      act_runner:
        container_name: act_runner
        image: docker.nju.edu.cn/gitea/act_runner
        networks:
            postgres:
        volumes:
            - ./config.yaml:/config.yaml
            - ./act_data:/data
            - /var/run/docker.sock:/var/run/docker.sock
        environment:
            CONFIG_FILE=/config.yaml
    
    networks:
      postgres:
        external: true


<a id="org3404042"></a>

### act<sub>runner</sub>

1.  创建配置文件

        docker run --entrypoint="" --rm -it docker.nju.edu.cn/gitea/act_runner:latest act_runner generate-config > config.yaml

2.  配置文件

        # Example configuration file, it's safe to copy this as the default config file without any modification.
        
        # You don't have to copy this file to your instance,
        # just run `./act_runner generate-config > config.yaml` to generate a config file.
        
        log:
          # The level of logging, can be trace, debug, info, warn, error, fatal
          level: info
        
        runner:
          # Where to store the registration result.
          file: .runner
          # Execute how many tasks concurrently at the same time.
          capacity: 1
          # Extra environment variables to run jobs.
          envs:
            A_TEST_ENV_NAME_1: a_test_env_value_1
            A_TEST_ENV_NAME_2: a_test_env_value_2
          # Extra environment variables to run jobs from a file.
          # It will be ignored if it's empty or the file doesn't exist.
          env_file: .env
          # The timeout for a job to be finished.
          # Please note that the Gitea instance also has a timeout (3h by default) for the job.
          # So the job could be stopped by the Gitea instance if it's timeout is shorter than this.
          timeout: 3h
          # Whether skip verifying the TLS certificate of the Gitea instance.
          insecure: false
          # The timeout for fetching the job from the Gitea instance.
          fetch_timeout: 5s
          # The interval for fetching the job from the Gitea instance.
          fetch_interval: 2s
          # The labels of a runner are used to determine which jobs the runner can run, and how to run them.
          # Like: "macos-arm64:host" or "ubuntu-latest:docker://gitea/runner-images:ubuntu-latest"
          # Find more images provided by Gitea at https://gitea.com/gitea/runner-images .
          # If it's empty when registering, it will ask for inputting labels.
          # If it's empty when execute `daemon`, will use labels in `.runner` file.
          labels:
            - "ubuntu-latest:docker://localhost/donjuan"
            - "donjuan:docker://git.donjuan.lecturify.net/donjuan/donjuan-workflow:latest"
        cache:
          # Enable cache server to use actions/cache.
          enabled: true
          # The directory to store the cache data.
          # If it's empty, the cache data will be stored in $HOME/.cache/actcache.
          dir: ""
          # The host of the cache server.
          # It's not for the address to listen, but the address to connect from job containers.
          # So 0.0.0.0 is a bad choice, leave it empty to detect automatically.
          host: ""
          # The port of the cache server.
          # 0 means to use a random available port.
          port: 0
          # The external cache server URL. Valid only when enable is true.
          # If it's specified, act_runner will use this URL as the ACTIONS_CACHE_URL rather than start a server by itself.
          # The URL should generally end with "/".
          external_server: ""
        
        container:
          # Specifies the network to which the container will connect.
          # Could be host, bridge or the name of a custom network.
          # If it's empty, act_runner will create a network automatically.
          network: ""
          # Whether to use privileged mode or not when launching task containers (privileged mode is required for Docker-in
        -Docker).
          privileged: false
          # And other options to be used when the container is started (eg, --add-host=my.gitea.url:host-gateway).
          options:
          # The parent directory of a job's working directory.
          # NOTE: There is no need to add the first '/' of the path as act_runner will add it automatically. 
          # If the path starts with '/', the '/' will be trimmed.
          # For example, if the parent directory is /path/to/my/dir, workdir_parent should be path/to/my/dir
          # If it's empty, /workspace will be used.
          workdir_parent:
          # Volumes (including bind mounts) can be mounted to containers. Glob syntax is supported, see https://github.com/
        gobwas/glob
          # You can specify multiple volumes. If the sequence is empty, no volumes can be mounted.
          # For example, if you only allow containers to mount the `data` volume and all the json files in `/src`, you shou
        ld change the config to:
          # valid_volumes:
          #   - data
          #   - /src/*.json
          # If you want to allow any volume, please use the following configuration:
          # valid_volumes:
          #   - '**'
          valid_volumes: []
          # overrides the docker client host with the specified one.
          # If it's empty, act_runner will find an available docker host automatically.
          # If it's "-", act_runner will find an available docker host automatically, but the docker host won't be mounted 
        to the job containers and service containers.
          # If it's not empty or "-", the specified docker host will be used. An error will be returned if it doesn't work.
          docker_host: ""
          # Pull docker image(s) even if already present
          force_pull: false
          # Rebuild docker image(s) even if already present
          force_rebuild: false
        
        host:
          # The parent directory of a job's working directory.
          # If it's empty, $HOME/.cache/act/ will be used.
          workdir_parent:

3.  注册act

        docker exec -it act_runner bash
        act_runner --config /config.yaml register
        # token为giteaweb的actions配置中的runner token

4.  启动act

        act_runner --config /config.yaml daemon


<a id="orgd346685"></a>

### gitea

1.  备份与恢复

    1.  备份
    
            docker exec -it gitea bash
            su git # 以app.ini中指定的用户登录
            gitea dump
        
        也可以使用数据库进行备份
        
            pg_dump -U $USER $DATABASE > gitea-db.sql
    
    2.  恢复
    
            # 在容器中打开 bash 会话
            docker exec --user git -it gitea bash
            # 在容器内解压您的备份文件
            unzip gitea-dump-1610949662.zip
            cd gitea-dump-1610949662
            # 恢复 Gitea 数据
            mv data/* /data/gitea
            # 恢复仓库本身
            mv repos/* /data/git/gitea-repositories/
            # 调整文件权限
            chown -R git:git /data
            # mysql
            mysql --default-character-set=utf8mb4 -u$USER -p$PASS $DATABASE <gitea-db.sql
            # sqlite3
            sqlite3 $DATABASE_PATH <gitea-db.sql
            # postgres
            psql -U $USER -d $DATABASE < gitea-db.sql
            # 重新生成 Git 钩子
            /usr/local/bin/gitea -c '/data/gitea/conf/app.ini' admin regenerate hooks


<a id="org7b432df"></a>

## postgres

docker-compose.yml

      # Use postgres/example user/password credentials
    version: '3.9'
    
    services:
    
      db:
        image: postgres
        restart: always
        # set shared memory limit when using docker-compose
        shm_size: 128mb
        # or set shared memory limit when deploy via swarm stack
        #volumes:
        #  - type: tmpfs
        #    target: /dev/shm
        #    tmpfs:
        #      size: 134217728 # 128*2^20 bytes = 128Mb
        volumes:
            - ./data:/var/lib/postgresql/data
        environment:
            POSTGRES_PASSWORD: example


<a id="org3341520"></a>

## overleaf

clone

    git clone https://github.com/overleaf/toolkit

    cd toolkit
    ./bin/init
    ./bin/up

前往<http://localhost/launchpad>


<a id="org37d30dc"></a>

## archlinux


<a id="org04e592c"></a>

### docker-compose.yml

    version: '3'
    
    services:
      gitea:
        container_name: archlinux
        image: archlinux
        network_mode: host
        volumes:
          - ./mirrorlist:/etc/pacman.d/mirrorlist
        tty: true
        stdin_open: true


<a id="org6ab20a4"></a>

## frp


<a id="org2f77dae"></a>

### compose

    version: '3.3'
    services:
        frps:
            network_mode: host
            volumes:
                - ./frps.ini:/etc/frp/frps.ini
            container_name: frps
            image: docker.nju.edu.cn/snowdreamtech/frps


<a id="orga425980"></a>

### frps.ini

    [common]
    bind_port = 6000
    vhost_http_port = 6001
    vhost_https_port = 6002
    dashboard_addr = 0.0.0.0
    dashboard_port = 6500
    dashboard_user = user
    dashboard_pwd = password
    subdomain_host = frp.yourdomain
    token = yourtoken


<a id="orgc060cc9"></a>

## rustdesk

key在data下的id<sub>ed25519.pub</sub>


<a id="orgef073f2"></a>

### compose

      version: '3'
    services:
      hbbs:
        container_name: hbbs
        image: docker.m.daocloud.io/rustdesk/rustdesk-server:latest
        command: hbbs
        volumes:
          - ./data:/root
        network_mode: "host"
        restart: unless-stopped
    
      hbbr:
        container_name: hbbr
        image: docker.m.daocloud.io/rustdesk/rustdesk-server:latest
        command: hbbr
        volumes:
          - ./data:/root
        network_mode: "host"
        restart: unless-stopped

data/id<sub>ed25519.pub</sub>


<a id="orgeb9ce89"></a>

## steamcmd

    docker run -it -v $PWD:/data steamcmd/steamcmd:latest +login anonymous +force_install_dir /data +app_update 740 +quit


<a id="org13717ff"></a>

## mariadb


<a id="org79ee3de"></a>

### compose


<a id="org7439412"></a>

### cli

-   创建数据库
    
        create database 'database';
-   创建用户
    
        create user 'user';
-   修改密码
    
        set password for 'user' = PASSWORD('password');
-   授予权限
    
        GRANT ALL PRIVILEGES ON 'database' TO 'user';
        flush privileges;


<a id="orgf0c169c"></a>

## mail-server


<a id="orge08f54d"></a>

### compose


<a id="org9d3733d"></a>

## v2raya


<a id="org8168e10"></a>

### cli

    podman run -itd   --name v2raya   --restart=always   --security-opt no-new-privileges   --cap-drop all   --network host   --memory=500M   --volume .:/etc/v2raya:z   docker.io/mzz2017/v2raya


