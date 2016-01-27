PROGRAM Way(INPUT, OUTPUT);
USES GraphABC, READING;
CONST S = 1001;
TYPE intDig = ARRAY [0 .. S, 0 .. S] OF INTEGER;
TYPE intSym = ARRAY [0 .. S, 0 .. S] OF CHAR;
VAR 
  StartX, StartY, FinishX, FinishY, SizeX, SizeY: INTEGER;
  statusWay: BYTE; {0 - No way, 1 - Labyrinth have way, 3 - ERROR}
  Digit: ARRAY [0 .. S, 0 .. S] OF INTEGER; {Array for processing}
  Symbol: ARRAY [0 .. S, 0 .. S] OF CHAR; {Array for save results}
{module 2}
PROCEDURE fillingArray(firstCoordinate, secondCoordinate, stepNumber: INTEGER);
BEGIN
  Digit[firstCoordinate, secondCoordinate] := stepNumber;
  statusWay := 1
END;
PROCEDURE fillingDigitArray(windowX, windowY, countSteps: INTEGER);
BEGIN
  IF Digit[windowX, windowY] = CountSteps - 1
  THEN
    BEGIN
      IF Digit[windowX + 1, windowY] = 0 {Wave propagation}
      THEN                
        fillingArray(windowX + 1, windowY, countSteps); {Right}
      IF Digit[windowX - 1, windowY] = 0
      THEN
        fillingArray(windowX - 1, windowY, countSteps);
      IF Digit[windowX, windowY + 1] = 0
      THEN
        fillingArray(windowX, windowY + 1, countSteps);
      IF Digit[windowX, windowY - 1] = 0
      THEN
        fillingArray(windowX, windowY - 1, countSteps) {Wave propagation}
    END    
END;

FUNCTION LetWaves(CountSteps: INTEGER): INTEGER;
VAR
  WindowY, WindowX: INTEGER;
BEGIN {WAVES}
  IF statusWay < 2 
  THEN
    statusWay := 1;
  WHILE (Digit[FinishX, FinishY] = 0) AND (statusWay = 1) {WAVES}
  DO
    BEGIN
      statusWay := 0; {Check for occupancy}
      FOR WindowY := 0 TO SizeY 
      DO
        FOR WindowX := 0 TO SizeX
        DO
          fillingDigitArray(WindowX, WindowY, CountSteps);
      INC(CountSteps) {Count Steps}  
    END; {WAVES}
  CountSteps := CountSteps - 2; {Subtract movement at the beginning and at the end}
  LetWaves := CountSteps
END; {WAVES}

PROCEDURE firstWayCoordinates(firstFinishCoordinate, secondFinishCoordinate: INTEGER; firstCoordinate, secondCoordinate: ^INTEGER);
BEGIN
  firstCoordinate^ := firstFinishCoordinate;
  secondCoordinate^ := secondFinishCoordinate;
  Symbol[firstCoordinate^, secondCoordinate^] := '*'
END;

PROCEDURE instalCoordinates(finishX, finishY, countSteps: INTEGER; WayX, WayY: ^INTEGER);
BEGIN
  IF Digit[finishX + 1, finishY] = countSteps {Check the box next and sets the first coordinate}
  THEN
    firstWayCoordinates(finishX + 1, finishY, WayX, WayY) {Setting coordinate beginning of the path}
  ELSE  
    IF Digit[finishX - 1, finishY] = countSteps 
    THEN
      firstWayCoordinates(finishX - 1, finishY, WayX, WayY) {Setting coordinate beginning of the path} 
    ELSE
      IF Digit[finishX, finishY + 1] = CountSteps 
      THEN
        firstWayCoordinates(finishX, finishY + 1, WayX, WayY) {Setting coordinate beginning of the path}
      ELSE
        IF Digit[finishX, finishY - 1] = CountSteps 
        THEN
          firstWayCoordinates(finishX, finishY - 1, WayX, WayY); {Setting coordinate beginning of the path} 
END;

PROCEDURE minWay(CountSteps, WayX, WayY: ^INTEGER);
BEGIN
  DEC(CountSteps^);
  IF Digit[WayX^ + 1, WayY^] = CountSteps^ {Check the box next and build the way}
  THEN
    firstWayCoordinates(WayX^ + 1, WayY^, WayX, WayY)
  ELSE  
    IF Digit[WayX^ - 1, WayY^] = CountSteps^ 
    THEN
      firstWayCoordinates(WayX^ - 1, WayY^, WayX, WayY)
    ELSE
      IF Digit[WayX^, WayY^ + 1] = CountSteps^ 
      THEN
        firstWayCoordinates(WayX^, WayY^ + 1, WayX, WayY)
      ELSE
        IF Digit[WayX^, WayY^ - 1] = CountSteps^ 
        THEN
          firstWayCoordinates(WayX^, WayY^ - 1, WayX, WayY)  
END;

PROCEDURE SearchWay(StartX, StartY, FinishX, FinishY: INTEGER);
VAR
  CountSteps, WayX, WayY: INTEGER;   
BEGIN {WAY}
  CountSteps := LetWaves(2);
  IF statusWay = 1 {Checking for path}
  THEN
    BEGIN
      IF (StartX <> FinishX) OR (StartY <> FinishY)
      THEN
        BEGIN
          instalCoordinates(FinishX, FinishY, CountSteps, @WayX, @WayY);    
          WHILE (Symbol[StartX, StartY] = 'O') AND (CountSteps >= 0)
          DO
            minWay(@CountSteps, @WayX, @WayY);
        END      
    END;   
END; {WAY} 
{module 2}
{module 3}
PROCEDURE verticalLines(Height, Number, Size: INTEGER);
BEGIN
  FOR Number := 0 TO (Size + 1)
  DO
    LINE(0, Height * Number, WINDOWWIDTH, Height * Number); 
END;

PROCEDURE horizontalLines(Height, Number, Size: INTEGER);
BEGIN
  FOR Number := 0 TO (size + 1)
  DO
    LINE(Height * Number, 0, Height * Number, WINDOWHEIGHT)
END;

PROCEDURE Draw(cellHeight, SizeX, SizeY: ^INTEGER);
VAR
  borderNumber: INTEGER;
BEGIN
  cellHeight^ := (SCREENHEIGHT DIV 2) DIV (SizeY^ + 1);
  SETWINDOWTOP(0);
  SETWINDOWLEFT(0);
  SETWINDOWSIZE(cellHeight^ * (sizeX^ + 1), cellHeight^ * (sizeY^ + 1));
  WINDOW.IsFixedSize := true;
  verticalLines(cellHeight^, borderNumber, SizeY^);
  horizontalLines(cellHeight^, borderNumber, SizeX^)
END;

PROCEDURE paint(WindowX, WindowY, height: INTEGER);
BEGIN
  CASE Symbol[WindowX, WindowY] OF
    '#': FLOODFILL(height DIV 2 + height * WindowX, height DIV 2 + height * WindowY, CLBLACK);
    'O': FLOODFILL(height DIV 2 + height * WindowX, height DIV 2 + height * WindowY, CLORANGE);
    '*': FLOODFILL(height DIV 2 + height * WindowX, height DIV 2 + height * WindowY, CLRED)
  END;
END;

PROCEDURE writeErrors(errorsNumber: BYTE);
BEGIN
  CASE errorsNumber OF
      2: WRITE('ERROR! YOU INTRODUCED MORE 2 WAY''S POINT FINAL'); 
      3: WRITE('ERROR! MAZE HAVEN''T ONE-PIECE WALL');
      4: WRITE('ERROR! YOU INTRODUCED 1 OR NOT WAY''S POINT FINAL')
    END   
END;

PROCEDURE Print(statusWay: BYTE; SizeX, SizeY: ^INTEGER);
VAR
  WindowX, WindowY, heightCell: INTEGER;
BEGIN
  Symbol[StartX, StartY] := 'O'; 
  IF statusWay < 2 
  THEN
    BEGIN
      Draw(@heightCell, SizeX, SizeY);
      FOR WindowY := 0 TO SizeY^ {Print Result}
      DO
        FOR WindowX := 0 TO SizeX^
        DO
          paint(WindowX, WindowY, heightCell) {Print Result}
    END
  ELSE
    writeErrors(statusWay)  
END;
{module 3} 
BEGIN
  ReadingFile(Digit, Symbol, @SizeX, @SizeY, @StartX, @StartY, @FinishX, @FinishY, @StatusWay);     
  SearchWay(StartX, StartY, FinishX, FinishY);
  Print(StatusWay, @SizeX, @SizeY)
END. {WAY}
