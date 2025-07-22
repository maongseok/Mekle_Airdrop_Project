// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title basic EVM Sig verification
 * @author mds
 *
 * Original Work by:
 * @author cyfrin-updraft
 * @notice https://updraft.cyfrin.io/courses/advanced-foundry/merkle-airdrop/signature-standards
 */
contract SignatureVerifier {
    /*//////////////////////////////////////////////////////////////
                            SIMPLESIGNATURES
    //////////////////////////////////////////////////////////////*/
    function getSignerSimple(uint256 message, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address) {
        bytes32 hashedMessage = bytes32(message); // if string we use keccak256(abi.encodePaced(string)) cant type cast
        address signer = ecrecover(hashedMessage, _v, _r, _s);
        return signer;
    }

    function verfiySignerSimple(uint256 message, uint8 _v, bytes32 _r, bytes32 _s, address signer)
        public
        pure
        returns (bool)
    {
        address actualSigner = getSignerSimple(message, _v, _r, _s);
        require(actualSigner == signer);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                              EIP191 VERSION 1
    //////////////////////////////////////////////////////////////*/
    function getSigner191(uint256 message, uint8 _v, bytes32 _r, bytes32 _s) public view returns (address) {
        // Arguments when calculation hash to validate
        // 1: byte(0x19) the initial 0x19 byte
        // 2: byte(0) - the version byte
        // 3: version specific data, for version 0, it's the intended validator address
        // 4: Application specific data  <data to sign>

        bytes1 prefix = bytes1(0x19);
        bytes1 eip191Version = bytes1(0);
        address intendedValidatorAddress = address(this);
        bytes32 applicationSpecificData = bytes32(message);

        //0x19 <1 byte version> <version specific data> <data to sign>
        bytes32 hashedMessage =
            keccak256(abi.encodePacked(prefix, eip191Version, intendedValidatorAddress, applicationSpecificData));

        address signer = ecrecover(hashedMessage, _v, _r, _s);
        return signer;
    }

    function verfiySigner191(uint256 message, uint8 _v, bytes32 _r, bytes32 _s, address signer)
        public
        view
        returns (bool)
    {
        address actualSigner = getSigner191(message, _v, _r, _s);
        require(actualSigner == signer);
        return true;
    }
}
