unit unit5;

interface

uses
  Generics.Collections,
  Forms, Classes, StdCtrls, Controls, Spin;

type OnePositions = array of integer;
//     StrContainer = TList<{RawByte}String>;
type

  { TForm1 }

  TForm5 = class(TForm)
    Button1: TButton;
    edOnes: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblResults: TLabel;
    Memo1: TMemo;
    edLen: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
//    procedure StoreResult( const L: integer; const P1: OnePositions );
//    procedure PositionRest( var Pos: OnePositions; const L, StartAt, Rest1s: integer );
//    procedure GenerateAll( const L,N: integer );
  public
    { public declarations }
//    var Results: StrContainer;
  end;

var
  Form5: TForm5;

implementation
uses OtlParallel, OtlCollections, OtlCommon,
     Dialogs, Windows, Math, SysUtils;

procedure Error;
begin
  raise Exception.Create ('We badly screwed'); // or whatever you would make it do
end;

//function StringOfChar( const Z: AnsiChar; L: integer): RawByteString;
//begin
//  SetLength(Result,L);
//  while L > 0 do begin
//    Result[L] := Z;
//    Dec(L);
//  end;
//end;

{ TForm1 }
{$R *.dfm}

function MakeResult( const L: integer; const P1: OnePositions ): string;
var i,Prev1,Next1: integer;
begin
  Result := StringOfChar( '0', L );
  Prev1 := 0;

  // if those Low/High functions are not yet implemented in Delphi7,
  // you may run the loop from 0 to Prev(Length(P1))
  // to go through all the P1 array elements
  for i := Low(P1) to High(P1) do begin
     Next1 := P1[i]; // position for next "1"
     if Next1 > Length(Result) then Error; // outside of string
     if Prev1 >= Next1 then Error;   //  Next "1" is left of previous "1"
     Result[Next1] := '1';
     Prev1 := Next1;     // tracing what was the right-most "1" inserted
  end;
end;

// L - string length, thus maximum position of "1"
// StartAt - the leftmost (minimal) position of the 1st left "1" to place
//    positions < StartAt already were taken
// Rest1s - how many "1" left to be placed (we still have to place)

{$A+} // not $A8
type CalcStage = Record Pos: OnePositions;
                        L, StartAt, Rest1s: integer; end;

procedure PositionRest( const input, output: IOmniBlockingCollection );
var Max, idx, NextRest1s, i: integer;
    si, so: CalcStage;
    vi: TOmniValue;
begin
  for vi in input do begin
    si := vi.ToRecord<CalcStage>;

    idx := Length(si.Pos) - si.Rest1s; // number of "1" we are setting now
    NextRest1s := si.Rest1s - 1;    // how many "1"s to be set by next calls
    Max := si.L - NextRest1s;       // rightmost part of string we have to leave free for next "1" to be placed

    so.L := si.L;
    so.Rest1s := NextRest1s;

    for i := si.StartAt to Max do begin
      si.Pos[idx] := i;     // placing our dear "1" here or there
      if NextRest1s = 0  // did we maybe just positioned the last "1" ?
         then output.Add( MakeResult( si.L, si.Pos ) )
         else begin
           // PositionRest( Pos, L, i+1, NextRest1s);

//           so.L := si.L;  // done above once per all loop
//           so.Rest1s := NextRest1s;
           so.StartAt := i+1;
           so.Pos := Copy(si.Pos); // COPY !!! DynArray is pointer, but we MUST replicate the CONTENT

           input.Add( TOmniValue.FromRecord(so) );
         end;
    end;
  end;
end;

//procedure GenerateAll( const L,N: integer );
//var Ones: OnePositions;
//begin
////  results := JclStringList();
//  SetLength(Ones,N);
//  PositionRest(Ones, L, 1, N);
//
////  results := nil;
//end;

procedure TForm5.FormCreate(Sender: TObject);
begin
//  Results := StrContainer.Create;
  lblResults.Caption := '';
end;

procedure TForm5.FormDestroy(Sender: TObject);
begin
//  Results.Free;
end;

{.$Define InputAlter}
procedure TForm5.Button1Click(Sender: TObject);
var L, N: integer;
    C: Cardinal;
    Msg: string;
    so: CalcStage;
    pipeIn, pipeOut: IOmniBlockingCollection;
    pipe:    IOmniPipeline;
    Results: TArray<String>;
const Limit = 100; // TMemo is working very bad with huge texts
begin
  // Results.Clear;
  L := edLen.Value;
  N := edOnes.Value;

  lblResults.Caption := ' WAIT, we are searching ...';
  Memo1.Clear;
  Repaint;

  C := GetTickCount();
    pipe := Parallel.Pipeline
{$IfDef InputAlter}
      .Stage(
        // GenerateAll( L, N );
        procedure ( const input, output: IOmniBlockingCollection )
        var so: CalcStage;
        begin
          //  SetLength(Ones,N);
          //  PositionRest(Ones, L, 1, N);
          SetLength(so.Pos, N);
          so.L := L;
          so.StartAt := 1;
          so.Rest1s := N;

          output.Add( TOmniValue.FromRecord(so) );
        end
      )
{$EndIf}
      .Stage( PositionRest );
{$IfNDef InputAlter}
    pipeIn := pipe.Input;
      SetLength(so.Pos, N);
      so.L := L;
      so.StartAt := 1;
      so.Rest1s := N;
    pipeIn.Add( TOmniValue.FromRecord(so) );
{$EndIf}

    pipe.Run;
//    pipeIn.CompleteAdding;

    pipe.WaitFor(INFINITE);
    pipeOut := pipe.Output;
    pipeOut.CompleteAdding;
    Results := TOmniBlockingCollection.ToArray<string>(pipeOut);
  C := GetTickCount() - C;

  Msg := Format('Found %u strings in %.3g seconds.', [Length(Results), C * 0.001]);
  lblResults.Caption := Msg;
  ShowMessage(Msg);
//  Repaint;

  N := Min( Length(Results), Limit);
  Memo1.Lines.BeginUpdate;
  try
    if Length(Results) <= Limit then
       Memo1.Lines.Add('Results are huge, here are first '+IntToStr(Limit)+' of them:...'^M^J);
    for L := 0 to Pred(N) do
      Memo1.Lines.Add(Results[L]);
  finally
    Memo1.Lines.EndUpdate;
  end;

//  Results.Clear;
end;

end.

