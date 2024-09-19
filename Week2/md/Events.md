#### How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable?

OpenSea can track NFTs owned by a particular address by listening to `Transfer` events emitted by NFT smart contracts. When an NFT is transferred, the contract emits a `Transfer` event with information about the sender (`from`), the receiver (`to`), and the token ID. 

To determine which NFTs an address owns, OpenSea filters these events, collecting instances where the `to` address matches the users address. This gives them a list of NFTs sent to that user. 

To keep the list updated, OpenSea continues to listen for `Transfer` events.

#### Explain how you would accomplish this if you were creating an NFT marketplace

Similar to OpenSea, I would listen to all `Transfer` events from relevant NFT contracts and store this data in an internal database. This would allow my marketplace to keep an up-to-date record of which NFTs belong to which addresses. For the frontend, the marketplace would query this internal database to serve the user with accurate and real-time information about their NFT holdings.