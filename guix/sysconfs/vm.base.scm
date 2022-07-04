(use-modules (gnu)
	     ((kefir misc base) #:prefix kefir-misc:))
(use-service-modules desktop networking ssh xorg docker)

(define my-system-supplementary-groups
  '("wheel" "netdev" "audio" "video" "docker"))

(define my-system-packages
  (append
   %base-packages
   (map (compose list specification->package+output)
	kefir-misc:system-packages)))

(define my-basic-services
  (modify-services
    %desktop-services
    (guix-service-type
     config => (guix-configuration
		(inherit config)
		(substitute-urls
		 '("https://mirror.sjtu.edu.cn/guix/"))))))

(define my-system-services
  (append
   my-basic-services
   (list
    (service openssh-service-type)
    (service docker-service-type))))

(operating-system
 (locale "en_US.utf8")
 (timezone "Europe/Moscow")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "base")
 (users (cons* (user-account
                (name "user")
                (comment "User")
                (group "users")
                (home-directory "/home/user")
                (supplementary-groups
                 my-system-supplementary-groups))
               %base-user-accounts))
 (packages my-system-packages)
 (services my-system-services)
 (bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (target "/dev/sda")
   (keyboard-layout keyboard-layout)))
 (mapped-devices
  (list (mapped-device
         (source
          (uuid "833de398-082b-4f91-8a03-1ba787b46e6f"))
         (target "cryptroot")
         (type luks-device-mapping))))
 (file-systems
  (cons* (file-system
          (mount-point "/")
          (device "/dev/mapper/cryptroot")
          (type "ext4")
          (dependencies mapped-devices))
         %base-file-systems)))
