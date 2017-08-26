# Logic for keeping secrets in the Vault

#devtools::install_github("gaborcsardi/secret")
library(secret)
#library(openssl)

## creating a vault in the working directory
# getting working directory to the variable original_wd
original_wd <- getwd()

# creating a vault named tormos
dir.create(file.path(original_wd, "tormos"))
create_vault(file.path(original_wd, "tormos"))

## adding users to the vault
# getting paths to the keys of the user
key_dir <- "C:/Users/fxtrams/.ssh"
pub_key_dir <- file.path(key_dir1, "id_rsa.pub") #directory for public key
prv_key_dir <- file.path(key_dir1, "id_rsa")
# reading public key with openssl package:
openssl::read_pubkey(pub_key_dir)
# adding users to the vault
#
# adding user to the vault myVault1
add_user("vzhomeexperiments", public_key = pub_key_dir, vault = "tormos")
add_github_user("vzhomeexperiments", vault = "tormos")
add_github_user("vladdsm", vault = "tormos")


# generating fake secret
fakepassword <- "MyFakePassword334455"

# add secret to the vault myVault1, share it for both users / also added new user from git and his key
add_secret(name = "TheFakeSecret", value = fakepassword, users = c("vzhomeexperiments",
                                                                    "github-vzhomeexperiments", 
                                                                    "github-vladdsm"), vault = "tormos")

add_secret(name = "TheFakeSecret1", value = fakepassword, users = c("vzhomeexperiments",
                                                                   "github-vzhomeexperiments", 
                                                                   "github-vladdsm"), vault = "tormos")

# this will 
update_secret(name = "TheFakeSecret", key = local_key(), value = fakepassword, vault = "tormos")
# get that secret usign the private key /user having private key/
secret_retrieved <- get_secret(name = "TheFakeSecret", key = prv_key_dir, vault = "tormos")
