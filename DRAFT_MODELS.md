Models

- GameState
    - GameId Integer
    - Phase Integer
    - CurrentUserTurn Integer (references PlayerTurnOrder Number)
    - CurrentCorpTurn Integer (references CorpTurnOrder Number)
- CorpTurnOrder
    - GameId Integer
    - CorpID Integer
    - Number Integer
- PlayerTurnOrder
    - GameId Integer
    - PlayerID Integer
    - Number Integer
- CorpsAndPlayers
    - GameId Integer
    - Name String
    - Id Integer
    - CashOnHand Integer
    - IsForeignInvestor Boolean
    - IsCorp Boolean
- OwnedCompanies
    - GameId Integer
    - PlayerID Integer
    - CompanyId Integer
- Company Object
    - GameId Integer
    - ID Integer
    - Name String
    - Symbol String
    - IsPublic Boolean
    - Owner  Integer
    - CashOnHand Integer
    - Value Integer
    - Payout Integer
    - MinRange Integer
    - MaxRange Integer
    - Closed Boolean
- AvailableCompanies
    - GameId Integer
    - CompanyID Integer
- ShareValues
    - GameId Integer
    - Value Integer
    - Id integer
    - OwningCorp integer
- SharesSoldThisRound
    - GameId Integer
    - Userid Integer
    - CompanyID Integer
- CorpShares
    - GameId Integer
    - ShareId Integer
    - CorpID Integer (references CorpsAndPlayers/Id)
    - Owner Integer (-1 if bank owned)

Repopulate this table every phase change:

- CorpsRemainingInPhase:
    - GameId Integer
    - CompanyId Integer
    - Passed Boolean

Clear offers after entering phase 7.

- Offers
    - GameId Integer
    - Value Integer
    - OfferingUserID Integer
    - CompanyID Integer
- PassedUsers
    - GameId Integer
    - UserId Integer
    - Passed Boolean

GameID = CreateGame()

CreateGame()

- GameID = CreateNewGameID()
- PopulateCompanies(GameID Integer)
- CreateForeignInvestor(GameID Integer)

UserID = AddUserToGame(GameId, UserName)
 This can be done as an argument to CreateGame()


#RollingStock()

- If Phase == 1 then
    - ShowPhase1()
- else if Phase == 2 then
    - ShowPhase2()
- else if Phase == 3 then
    - ShowPhase3()
- else if Phase == 4 then
    - ResetPlayerTurnOrder()
    - ProcessForeignInvestor()
    - ChangePhase()
- else if Phase == 6
    - ShowPhase6()
- else if Phase == 7
- else if Phase == 8
- else if Phase == 9
- else if Phase == 10

#ShowPhase1()

- If CorpsHaveNotPassed() and  currentUserOwnsCurrentCorp()
    - ShowCorpToIssueShare

IssueShare(GameId Integer, CorpId Integer)

- Assign Share to Owner
- Assign Another share to bank
- AddToCorp
- Increment CurrentCorpTurn

Void CorpPass(GameID Integer, CorpId Integer)

- Increment CurrentCorpTurn

#ShowPhase2()

- If PlayerHasNotPassed(GameID integer, Playerid integer)
    - Foreach GetOwnedCompany()
        - ShowFormCorp()

CompanyIDs[] Integer GetOwnedCompanies(GameID Integer, UserID Integer)

ConvertCompanyToCorp(GameID Integer, CompanyID Integer, UserID Integer)

#ShowPhase3()

- If AllPlayersNotPassed() and CurrentPlayersTurn()
    - If AuctionOccurring()
        - DoAuctionStuffHere?
    - else
        - ShowSharesInBank(GameID )
        - ShowOwnedShares(GameID , PlayerID )
        - ShowAvailableCompanies()
- Else
    - ChangePhase()

BuyShare(GameID Integer, PlayerID integer, ShareID integer)

- Set Share new Owner
- IncreaseCorpValue(GetShareCorp(GameID, ShareId ))
- IncrementTurn()

SellShare(GameID Integer, PlayerID Integer, ShareId Integer)

- ReduceCorpValue(GetShareCorp(GameID, ShareId ))
- IncrementTurn()

StartAuction(GameID Integer, CompanyID)

Void BuyCompany(GameID Integer, UserId Integer, CompanyID Integer)

- ChangeOwnerofCompany(CompanyID, Userid)
- AdjustCash(GameId, UserID, - Amount)

Void AdjustCash(GameID Integer, UserID Integer, Amount Integer)
Corp Integer GetShareCorp(GameID Integer, ShareId Integer)
Void ReduceCorpValue(GameID Integer, CorpId Integer)
Void IncreaseCorpValue(GameID Integer, CorpId Integer)

Void PlayerPass(GameId Integer, PlayerID Integer)

- IncrementTurn()

#TODO:

- Player Bid
- Handle end of auction without breaking Passing

#Phase 5

ProcessForeignInvestor()

- Price = GetPriceOfCompany(GetCheapestCompany(GameID))
- While (GetCashOnHandForUser(GameID, GetForeignInvestorID(GameID)) >  Price)
    - BuyCompany(GameID, UserId, CompanyID)
    - Price = GetPriceOfCompany(GetCheapestCompany(GameID))

Integer GetForeignInvestorID(GameID Integer)
Integer GetCheapestCompany(GameId Integer)
Integer GetPriceOfCompany(GameId Integer, CompanyID Integer)
Integer GetCashOnHandForUser(GameID Integer, UserID Integer)

#Phase6
ShowPhase6()

This should be done without turn order, I believe.
This needs to be shown for all users and for all corps.  So we would need to track both User and Corp passing before leaving this phase.

- If CorpsHaveNotPassed() and UsersHaveNotPassed()
    - ShowOwnedCompanies(GameID)
    - ShowYourCompanies(GameID, UserID)
    - ShowOffers()
- Else
    - ChangePhase()

ShowOwnedCompanies(GameID)

- Get all companies that are not owned by non-corporate players

Id = CreateOffer(GameID Integer, CompanyID Integer, CorpId Integer, Amount Integer)

# Need some way to track which offers have been made and which have been declined. :-/

AcceptOffer(GameID Integer, OfferID Integer)

- Amount = GetOfferAmount(GameId, OfferID)
- Company = GetCompanyOfOffer(GameId, OfferID))
- Owner = GetOwnerOfCompany(Company)
- OtherUser = GetUserOffering(GameID, OfferID)
- If UserId == Owner
    - #this means  you are selling.
    - AdjustCash(GameId, UserID, Amount)
    - AdjustCash(GameID, OtherUser, - Amount)
    - ChangeCompanyOwner(GameID, Otheruser, Company)
- Else
    - AdjustCash(GameID, UserID, - Amount)
    - AdjustCash(GameID, OtherUser, Amount)
    - ChangeCompanyOwner(GameID, User, Company)
- DeleteOffer(GameID, OfferID)

ChangeCompanyOwner(GameID Integer, UserID Integer, CompanyID Integer)
Amount Integer = GetOfferAmount(GameID Integer, OfferID Integer)
DeleteOffer(GameID Integer, OfferID Integer)
GetOwnerOfCompany(GameID Integer, OfferId Integer)
GetCompanyOfOffer(GameID Integer,OfferID Integer)
GetUserOffering(GameID Integer, OfferID Integer)
CorpPass(GameID, CorpId)

Boolean CorpsHaveNotPassed()

- Returns true if any CorpsRemainingInPhase/Passed == False

ChangePhase()

- If Phase<10 Then
    - Phase++
- If Phase == 5 then
    - Phase = 6
- If Phase==10 Then
    - Phase = 1
- ClearPassedUsers()
- ClearSoldThisRound()
- RepopulateCorpsRemainingInPhase()

Methods:

Delta Integer StockChange(BookValue integer)
Boolean CanMakeOffer(id Integer)
Pass(id)
MakeOffer(PlayerID Integer, CompanyID, value Integer)
ShowOffers(PlayerID Integer)
Boolean IsPhaseDone()
Boolean AllPassed()
