pragma solidity >=0.5.0 <0.9.0;

import "./Owner.sol";

contract BookLibrary is Owner {
    struct Book {
        uint id;
        string title;
        string author;
        uint16 copies;
    }
    
    Book[] books;
    address[] users;
    
    mapping(address => uint[]) userToBooks;
    
    modifier isBookIdValid(uint _bookId) {
        require(_hasDuplicateBookId(_bookId), "Book id is invalid!");
        _;
    }
    
    modifier hasEnoughCopies(uint _bookId) {
        uint bookIndex = _getBookArrayIndex(_bookId);
        require(books[bookIndex].copies >= 1, "Book has no copies left!");
        _;
    }
    
    modifier isNotBorrowedByThisUser(uint _bookId, address _user) {
        
        uint[] memory borrowedBooks = userToBooks[_user];
        bool isAlreadyBorrowed = false;
        
        for (uint i = 0; i < borrowedBooks.length; i++) {
            if (borrowedBooks[i] == _bookId) {
                isAlreadyBorrowed = true;
            }
        }
        
        require(!isAlreadyBorrowed, "You have already booked that book!");
        _;
    }
    
    function _hasDuplicateBookId(uint _bookId) internal view returns (bool) {
        for (uint i = 0; i < books.length; i++) {
            if (books[i].id == _bookId) {
                return true;
            }
        }
        
        return false;
    }
    
     function _getBookArrayIndex(uint _bookId) internal view returns (uint) {
        
        uint index;
        
        for (uint i = 0; i < books.length; i++) {
            if (books[i].id == _bookId) {
                index = i;
                return index;
            }
        }
        
        return index;
    }
    
    function _isUserInUsersList(address _user) internal view returns (bool) {
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == _user) {
                return true;
            }
        }
        
        return false;
    }
    
    function addBook(uint _id, string memory _title, string memory _author, uint16 _copies) external isOwner {
        require(!_hasDuplicateBookId(_id), "Id is already used!");
        require(_copies > 0, "Copies count cannot be zero!");
        
        books.push(Book(_id, _title, _author, _copies));
    }
    
    function addBookCopies(uint _bookId, uint16 _copies) external isOwner {
         require(_copies > 0, "Copies count cannot be zero or less!");
         
         uint bookIndex = _getBookArrayIndex(_bookId);
         
         books[bookIndex].copies += _copies;
    }
    
    function listBooks() external view returns (Book[] memory){
        return books;
    }
    
    function listUsers() external view returns (address[] memory){
        return users;
    }
    
    function borrowBook(uint _bookId) external isBookIdValid(_bookId) hasEnoughCopies(_bookId) isNotBorrowedByThisUser(_bookId, msg.sender) {
        uint bookIndex = _getBookArrayIndex(_bookId);
        
        books[bookIndex].copies--;
        userToBooks[msg.sender].push(_bookId);
        
        if (!_isUserInUsersList(msg.sender)) {
            users.push(msg.sender);
        }
    }
    
    function returnBook(uint _bookId) external isBookIdValid(_bookId) {
        
        uint[] storage borrowedBooks = userToBooks[msg.sender];
        bool isAlreadyBorrowed = false;
        
        for (uint i = 0; i < borrowedBooks.length; i++) {
            if (borrowedBooks[i] == _bookId) {
                isAlreadyBorrowed = true;
            }
        }
        
        require(isAlreadyBorrowed, "You cannot return book that you dont have!");
        
        uint bookIndex = _getBookArrayIndex(_bookId);
        
        books[bookIndex].copies++;
        
        for (uint i = 0; i < borrowedBooks.length; i++) {
            if (borrowedBooks[i] == _bookId) {
                borrowedBooks[i] = borrowedBooks[borrowedBooks.length - 1];
                delete borrowedBooks[borrowedBooks.length - 1];
            }
        }
    }
}
