#use those commands mannualy
forge create src/BagelToken.sol:BagelToken --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account metamask --legacy --zksync
export TOKEN_ADDRESS
## the --constructor-args-path was a hell journey to fix for hours even ai did not suggest it
forge create src/MerkleAirdrop.sol:MerkleAirdrop --constructor-args-path src/constructorArg.txt --rpc-url https://zksync-sepolia.g.alchemy.com/v2/M4s1MBardMualBY3foryT --account metamask --legacy --zksync
gacy --zksync
export AIRDROP_ADDRESS
export ROOT=0x67ff2810c6ff1a2dec2da5ab404b4fb6c8ffdecb64cb920c539d234a786caab6
## sig process
cast call $(AIRDROP_ADDRESS) "getMessageHash(address,uint256)" 0x93e143cF1c097f5151C248D6B6c8EE4F7C4831Ac 25000000000000000000 --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL}

cast wallet sign --no-hash .... --account Receiver
forge script script/SplitSignature.s.sol:SplitSignature
export V_VAL=<v_value_output_by_script>
export R_VAL=<r_value_output_by_script>
export S_VAL=<s_value_output_by_script>

# mint token
cast send 0xDb378B3C4E24aA05950EeFc61349c38ba76D85CB "mint(address,uint256)" 0xE0DAe1365B16bD1e69a2596A12DBF77f0f7Be716 250000000000000000000 --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account metamask --legacy --zksync
# this command keep sending to the address it self use metamask hhhhhh it was pain hhhhhhhhhhh thanks for foundry zksync team for wating my time
cast send 0xDb378B3C4E24aA05950EeFc61349c38ba76D85CB "transfer(address,uint256)" ${AIRDROP} 100000000000000000000 --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account metamask --legacy --zksync
25000000000000000000
# redeem the airdrop
 merkleAirdrop : 0xB74B7Cf3998E58ceF141c2a912f4aD8719D3414b 
cast send ${AIRDROP} "claim(address,uint256,bytes32[],uint8,bytes32,bytes32)" ${RECIEVER} ${AMOUNT} "[0x4fd31fee0e75780cd67704fbc43caee70fddcaa43631e2e1bc9fb233fada2394,0x81f0e530b56872b6fc3e10f8873804230663f8407e21cef901b8aeb06a25e5e2]" ${V} ${R} ${S}  --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account metamask --legacy --zksync












## i can do this into .env but i want to upload thos to the github so i can remember the pain hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh

 merkleAirdrop : 0xB74B7Cf3998E58ceF141c2a912f4aD8719D3414b 
0xDb378B3C4E24aA05950EeFc61349c38ba76D85CB

msg = 0x1cceac445dc345518f08424addfa3a504bff0e83508111aa7e5c2809b17790d1
sig = 82991029f46a01cc785fe6e610ab419b9a9f04883e11d46c50bcb3690ec051ce35ad7e445ab78ead9c9ed0f3fdb6ab47d5198cb72797e5b9a79f1f7b28a369061b

  v value:
  27
  r value:
  0x82991029f46a01cc785fe6e610ab419b9a9f04883e11d46c50bcb3690ec051ce
  
  s value:
  0x35ad7e445ab78ead9c9ed0f3fdb6ab47d5198cb72797e5b9a79f1f7b28a36906

# put in .env 
RECIEVER=0x93e143cF1c097f5151C248D6B6c8EE4F7C4831Ac
AMOUNT=25000000000000000000
V=27
R=0x82991029f46a01cc785fe6e610ab419b9a9f04883e11d46c50bcb3690ec051ce
S=0x35ad7e445ab78ead9c9ed0f3fdb6ab47d5198cb72797e5b9a79f1f7b28a36906
AIRDROP=0xB74B7Cf3998E58ceF141c2a912f4aD8719D3414b
