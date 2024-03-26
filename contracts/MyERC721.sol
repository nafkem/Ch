
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} tokenId token is transferred to this contract via {IERC721-safeTransferFrom}
     * by operator from from, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with IERC721Receiver.onERC721Received.selector.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract MyERC721 {
    string private _name;
    string private _symbol;
    uint256 private _tokenIdCounter;
    address public Owner;

    mapping(uint256 => address) private _tokenOwners;
    mapping(address => uint256) private _ownershipTokenCount;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    modifier onlyOwner(address _addr) {
        require(_addr == Owner, "unauthorized access");
        _;
    }
    constructor(string memory _NAME, string memory _NAE, string memory _tokenuri) {
        _name = _NAME;
        _symbol = _NAE;
        Owner = msg.sender;

        mint(msg.sender, 1, _tokenuri);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _ownershipTokenCount[owner];
    }

function mint(address _to, uint tokenid, string memory _uri) public onlyOwner(msg.sender) returns (bool) {
        _mint(_to, tokenid, _uri);
        return true;
    
}

    function setTokenURI(uint256 tokenId, string memory uri) external onlyOwner(msg.sender) {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory _tokenURI = _tokenURIs[tokenId];
        return bytes(_tokenURI).length > 0 ? _tokenURI : "";
    }
function chhangeOwner(address _newowner) external onlyOwner(msg.sender) returns (bool) {
    require(_newowner != address(0), "address can't be null");
    Owner = _newowner;
    return true;
}
// making the function ownerOf() external while using it inside the contract will throw errors
// external functions can only be called outside the contract not in it so i'm changing it
//  to public since it can be used botth externally and internally

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function approve(address to, uint256 tokenId) external {
        
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        // the error here is due to the getapproved function of external visibility an externally
        // visible function can't b used inside the contract so i'm setting it to public
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);
        _ownershipTokenCount[from]--;
        _ownershipTokenCount[to]++;
        _tokenOwners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }


// THE _CHECKONERC721RECEIVED IS USED TO ENSURE THAT NFT IS NOT SENTT TO A CONTACT THAT DOSNT IMPLEMENT 
// THE ERC721 STANDARD TO PREVENT ASSETS BEINGG STUCK
// THE IERC721Receiver CAN B IMPORTED FROM OPENZEPELLIN
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool) {
        // THE IS CONTRACT FUNCTION IS UUSED IN THE WRONG WAY TH TO ADDRESS SHOULD BE PASSED
        // AS ARGUMENT INSTEAD ALSO THE FUNTION NAME IS _ISCONTRACT NOT ISCONTRACT 
        if (!_isContract(to)) {
            return true;
        }
        // IERC721 is not defined
        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
        _mint(to, tokenId, "");
    }

    function _mint(address to, uint256 tokenId, string memory _tokenURI) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwners[tokenId] = to;
        _ownershipTokenCount[to]++;
        _tokenIdCounter ++;
        _tokenURIs[tokenId] = _tokenURI; 
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);

        _clearApproval(tokenId);
        _ownershipTokenCount[owner]--;
        _tokenOwners[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}