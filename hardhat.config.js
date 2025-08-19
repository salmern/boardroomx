/** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.28",
// };


require("hardhat-circom");

module.exports = {
  solidity: "0.8.28",
  circom: {
    inputBasePath: "./circuits",
    outputBasePath: "./circuits/compiled",
    circuits: [{ name: "vote" }]
  }
};