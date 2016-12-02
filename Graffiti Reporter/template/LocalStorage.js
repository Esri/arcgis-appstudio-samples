var appname = "GeoReporter"

function _getDatabase() {
     return LocalStorage.openDatabaseSync(appname, "0.1", appname+"Database", 1*1024*1024);
}

function initTable(table) {
    var db = _getDatabase();
    var res = "";
    db.transaction(function(tx) {
         tx.executeSql('CREATE TABLE IF NOT EXISTS ' + table + '(key TEXT UNIQUE, value TEXT)');
    });
    return res;
}

function dropTable(table) {
    var db = _getDatabase();
    var res = "";
    db.transaction(function(tx) {
         tx.executeSql('DROP TABLE IF EXISTS ' + table + ';');
    });
    return res;
}



function set(table, key, value) {
    console.log("LocalStorage:: Set for: ", table, key, value)
   var db = _getDatabase();
   var res = "";
   db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS ' + table + '(key TEXT UNIQUE, value TEXT)');
        var rs = tx.executeSql('INSERT OR REPLACE INTO ' + table + ' VALUES (?,?);', [""+key,value]);
              if (rs.rowsAffected > 0) {
                res = "OK";
              } else {
                res = "Error";
              }
        }
  );
  return res;
}

function getCount(table) {
    console.log("LocalStorage:: inside getCount");
    var db = _getDatabase();
    var res= 0;
    try {
        db.transaction(function(tx) {
          tx.executeSql('CREATE TABLE IF NOT EXISTS ' + table + '(key TEXT UNIQUE, value TEXT)');
          var rs = tx.executeSql('SELECT COUNT(*) as total FROM ' + table + ';');
          console.log("LocalStorage:: total rows ", rs.rows.length);
          if (rs.rows.length > 0) {
              console.log("LocalStorage:: item ", JSON.stringify(rs.rows.item(0)));
              res = rs.rows.item(0).total;
          }
       })
    } catch (err) {
        console.log("Database " + err);
    };
   return res
}

function remove(table, key) {
    console.log("LocalStorage:: inside remove for ", table, key);
    var db = _getDatabase();
    var res = false;
    try {
        db.transaction(function(tx) {
          var rs = tx.executeSql('DELETE FROM ' + table + ' WHERE key=?;',[""+key]);
          console.log("LocalStorage:: total rows ", rs.rows.length);
          if (rs.rows.length > 0) {
              console.log("LocalStorage:: item ", JSON.stringify(rs.rows.item(0)));
              //res = rs.rows.item(0).total;
              res = true;
          }
       })
    } catch (err) {
        console.log("Database " + err);
        res = false;
    };
   return res;
}

function getAll(table) {
    console.log("LocalStorage:: inside get all for: ", table);
  var db = _getDatabase();
  var res=[];
  try {
      db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM ' + table + ';');
        console.log("LocalStorage:: total rows ", rs.rows.length);
        for (var i=0;i<rs.rows.length; i++ ) {
             //console.log("LocalStorage:: item ", JSON.stringify(rs.rows.item(0)));
             res.push(rs.rows.item(i).value);
        }
     })
  } catch (err) {
      //console.log("Database " + err);
      res = [];
  };
 return res
}

function get(table, key, default_value) {
     console.log("LocalStorage:: inside get for: ", table, key);
   var db = _getDatabase();
   var res="";
   try {
       db.transaction(function(tx) {
         var rs = tx.executeSql('SELECT value FROM ' + table + ' WHERE key=?;', [""+key]);
         console.log("LocalStorage:: total rows ", rs.rows.length);
         if (rs.rows.length > 0) {
              //console.log("LocalStorage:: item ", JSON.stringify(rs.rows.item(0)));
              res = rs.rows.item(0).value;
         } else {
             res = default_value;
         }
      })
   } catch (err) {
       //console.log("Database " + err);
       res = default_value;
   };
  return res
}
