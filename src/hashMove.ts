import SHA256 from "crypto-js/sha256";

export function hash(secret, salt) {
  console.log(secret, salt);
  // secret = secret.toString();
  let hash = SHA256(salt + secret);
  hash = hash.toString();

  console.log("before toString hash:", hash);
  console.log("hash", typeof hash, hash);
  // return hash
  let tempArr = Array();
  tempArr.push(secret);
  return tempArr;
}
