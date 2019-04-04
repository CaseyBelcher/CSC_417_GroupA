// npm i -D readline process typescript ts-node @types/node
// node_modules/.bin/ts-node dom.ts
"use strict";
import * as readline from 'readline';

class RowBuilder {
  row: Array<number|string>;

  constructor() {
    this.row = [];
  }
  addColumn(value: number|string) {
    this.row.push(value);
  }
  get(idx: number) {
    return Number(this.row[idx]);
  }
  getString() {
    let temp: string = "";
    for (let i = 0; i < this.row.length - 1; i++) {
      temp = temp + this.row[i] + ",";
    }
    temp = temp + this.row[this.row.length - 1];
    return temp;
  }
}

class IO {
  // Properties
  reader: readline.Interface;

  constructor() {
    this.reader = readline.createInterface({
      input: process.stdin //,
      // output: process.stdout
    });
  }
  
  getReader(): readline.Interface {
    return this.reader;
  }
  
  close() {
    this.reader.close();
  }
}

class Num {
  // Average
  mu: number = 0;
  // ??
  m2: number = 0; 
  // Min
  lo: number = 0;
  // Max
  hi: number = 0;
  // Number of elements in the column (for averaging)
  n: number = 0;
  // Stdev
  sd: number = 0;
  // The header label
  label: string;
  // <, >, or ? if neither < or >
  w: string;
  // -1 if <, 1 if >, NaN
  wAsNumber: number = NaN;
  // The position in the table
  idx: number;

  numInc(x: number): void { 
    this.n += 1; 
    let d = x - this.mu; 
    this.mu = this.mu + (d/this.n); 
    this.m2 = this.m2 + d*(x - this.mu);
    if(x > this.hi) { 
      this.hi = x; 
    } 
    if(x < this.lo) { 
      this.lo = x; 
    }
    if(this.n >= 2) { 
      this.sd = (this.m2/(this.n - 1 + 10**-32))**0.5; 
    }
  }
}

class Main {
  constructor() {}

  static main() {
    let io: IO = new IO();
    let rowBuilders: Array<RowBuilder> = [];
    // let rowLabels: Array<string> = null;
    // let rowSymbols: Array<string> = null;
    let columnsArray: Array<Num> = [];
    let headerLine: String = "";  
    
    io.getReader().on("line", (line) => {
      if (columnsArray.length === 0) {
        // We are on the header line
        // "hello world".replace(/\s/g, "");
        headerLine = line.replace(/\s/g, ""); 
        columnsArray = line.split(",").map((colLabel, idx) => {
          let num = new Num();
          // Set label
          num.label = colLabel;
          // Set type (<, >, or ?)
          let typeString: String = colLabel.trim().charAt(0); 
          if(typeString == '>') { 
            num.w = '>';
            num.wAsNumber = 1;
          }
          else if(typeString == '<') { 
            num.w = '<';
            num.wAsNumber = -1;
          }
          else { 
            num.w = '?';
          }
          
          // Set the position in the table
          num.idx = idx;
          return num;
        });
        // process.exit();
      } else {
        //TODO: Maybe this should be a factory
        // We are not on a header row
        let rowBuilder = new RowBuilder();
        
        // Bryan we should probably manually split this into an array
        let cols: Array<string> = line.split(",");
        for (let i = 0; i < cols.length; i++) {
          rowBuilder.addColumn(Number(cols[i]));
          if(columnsArray[i].w !== "?") { 
            columnsArray[i].numInc(Number(cols[i])); 
          }
        }
        
        rowBuilders.push(rowBuilder);
      }
      //io.close();
    }).on('close', () => {
      console.log("I am inside the code");
      
      let domCalculator: DomCalculator = new DomCalculator(rowBuilders, columnsArray);
      console.log(headerLine + 
        ",>dom" + "\n" + 
        domCalculator.calculate());
      console.log("Done!");
    });
  }
}

class DomCalculator{
  rowBuilders: Array<RowBuilder>;
  // contains nums data (statistics) for each column of table 
  columnsArray: Array<Num>;
  // Number of samples
  numSamples: number = 100;
  
  constructor(rowBuilders: Array<RowBuilder>, columnsArray: Array<Num>) {
    this.columnsArray = columnsArray;
    this.rowBuilders = rowBuilders;
    if(this.rowBuilders.length <= 100) { 
      this.numSamples = this.rowBuilders.length - 1; 
    }
  }

  // Replaces doms
  calculate(): String {
    for (let i=0; i<this.rowBuilders.length; i++) {
      let domScore = 0;
      let row1 = this.rowBuilders[i];
      let iter = 1; 
      let comparisonRows = this.randomized(i, this.numSamples);
      for (let i = 0; i < comparisonRows.length; i++) {
        const row2 = comparisonRows[i]; 
        // Iterate over the randomly selected rows
        domScore += this.dom(row1, row2) ? 1/this.numSamples : 0;
        iter++; 
      }
      
      this.rowBuilders[i].addColumn(domScore.toFixed(2));
    }

    let output = []; 
    for(let i = 0; i < this.rowBuilders.length; i++) { 
      output.push(this.rowBuilders[i].getString()); 
      output.push("\n")
    } 
    return output.join(""); 

  }

  dom(row1: RowBuilder, row2: RowBuilder) {
    let s1: number = 0;
    let s2: number = 0;
    // Number of optimize columns
    let n: number = this.columnsArray.filter(col => {
      return col.w == '>' || col.w == '<';
    }).length;

    this.columnsArray.map(col => {
      if (col.w === '?') {
        // Skip all non optimized columns
        return;
      }
      let row1Value: number = row1.get(col.idx);
      let row2Value: number = row2.get(col.idx);
      let a: number = this.numNorm(col, row1Value);
      let b: number = this.numNorm(col, row2Value);
      s1 -= 10**(col.wAsNumber * (a - b)/n );
      s2 -= 10**(col.wAsNumber * (b - a)/n );
    });
    return s1/n < s2/n;
  }
  
  numNorm(column: Num, value: number) {
    return (value - column.lo) / (column.hi - column.lo + 10e-32);
  }
  
  randomized(row1Idx: number, size: number): Array<RowBuilder> {
    // Duplicate array, remove row1 index
    let ret: Array<RowBuilder> = [...this.rowBuilders]; 
    ret.splice(row1Idx, 1); 
    for (let i=0; i < ret.length; i++) {
      // Randomizes the array
      let j = Math.floor(Math.random() * ret.length);
      [ret[i], ret[j]] = [ret[j], ret[i]];
    }
    // Returns only size elements
    let output = ret.slice(0, size);
    return output; 
  }
}

Main.main();
