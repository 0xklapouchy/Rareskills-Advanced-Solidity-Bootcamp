#### How does ERC721A save gas?

ERC721A saves gas by optimizing batch minting and reducing storage operations.

- `Batch minting`: Updates ownership data only once for multiple tokens minted in a single transaction, rather than individually for each token. Data is only updated for the first token in the batch, all sequential tokens data is not populated, but is possible to determinate via modified view functions.
- `Tokens metadata`: Removing redundant storage of each tokens metadata.
- `Sequential token IDs`: Uses linear token ID assignment.

#### Where does ERC721A add cost?

- `Transfer`: Transfers are more expensive because the contract must find ownership for batch-minted tokens.
- `Owner lookup`: Added logic for handling ownership increases complexity and gas costs.
- `Small mints`: The optimization is most effective for large mints. Minting one or few tokens may incur higher costs than standard ERC721.