import sha256 from "crypto-js/sha256";

export function hash(secret, salt) {
  console.log(secret, salt);
  let hash = sha256(secret + salt);
  hash = hash.toString();
  console.log("hash", typeof hash, hash);
  return hash.toString();
}
