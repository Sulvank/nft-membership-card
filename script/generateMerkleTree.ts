import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';
import fs from 'fs';

// This is vm.addr(1) in Foundry
const whitelistedAddr = '0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf';

const whitelist = [whitelistedAddr];

// Generate the Merkle tree
const leafNodes = whitelist.map(addr => keccak256(addr));
const tree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

const root = tree.getHexRoot();
const proof = tree.getHexProof(keccak256(whitelistedAddr));

// Save file
fs.writeFileSync(
  'script/merkle-output.json',
  JSON.stringify(
    {
      merkleRoot: root,
      whitelist: whitelist,
      proofs: {
        [whitelistedAddr]: proof
      }
    },
    null,
    2
  )
);

console.log('✅ Merkle tree generated and saved to script/merkle-output.json');