//
// Copyright (c) 2010, Yang Jiandong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2010-9-22  Yang Jiandong  Creation
//
using sql
using concurrent
**
** session and manager
** 
const class Context
{
  ** current sqlService
  const SqlService db
  ** mapping table model
  const Type:Table tables
  ** power of sql
  private const Executor executor:=Executor()
  private const Log log:=Pod.of(this).log
  
  new make(SqlService db,Type:Table tables){
    this.db=db
    this.tables=tables
  }
  
  ** get type's mapping table
  Table getTable(Type t){
    return tables[t]
  }
  
  ////////////////////////////////////////////////////////////////////////
  //tools
  ////////////////////////////////////////////////////////////////////////
  **
  ** find the persistence object,@Ignore facet will ignore the type
  ** 
  static Type:Table mappingTables(Type:Table tables,Pod pod,
                              SlanDialect dialect:=MysqlDialect()){
    pod.types.each|Type t|{
      if(t.hasFacet(Persistent#)){
        if(!t.hasFacet(Serializable#)){
          throw MappingErr("entity $t.name must be @Serializable")
        }
        table:=Table.mappingFromType(t,dialect)
        tables[t]=table
      }
    }
    return tables
  }
  **
  ** using connection finally will close.
  ** return a result than #use
  ** 
  Obj? ret(|Context->Obj?| f){
    try
    {
      db.open
      return f(this)
    }
    catch (Err e)
    {
      throw e
    }
    finally
    {
      db.close
    }
  }
  **
  ** using connection finally will close
  ** 
  Void use(|This| f){
    ret(f)
  }
  
  ////////////////////////////////////////////////////////////////////////
  //execute write
  ////////////////////////////////////////////////////////////////////////
  
  ** insert this a obj to database
  virtual Void insert(Obj obj){
    table:=getTable(obj.typeof)
    use{
    this.executor.insert(table,this.db,obj)
    }
  }
  ** update by id
  virtual Void update(Obj obj){
    table:=getTable(obj.typeof)
    use{
    this.executor.update(table,this.db,obj)
    }
  }
  ** delete by example
  virtual Void delete(Obj obj){
    table:=getTable(obj.typeof)
    use{
    this.executor.delete(table,this.db,obj)
    }
  }
  
  ////////////////////////////////////////////////////////////////////////
  //select id
  ////////////////////////////////////////////////////////////////////////
  ** select by example
  Obj[] select(Obj obj,Str orderby:="",Int offset:=0,Int limit:=20){
    Obj[] ids:=getIdList(obj,orderby,offset,limit)
    return idToObj(obj.typeof,ids)
  }
  ** select by example and get the first one
  Obj? one(Obj obj,Str orderby:="",Int offset:=0){
    Obj[] ids:=getIdList(obj,orderby,offset,1)
    
    if(ids.size==0)return null
    return findById(obj.typeof,ids[0])
  }
  
  protected virtual Obj[] getIdList(Obj obj,Str orderby,Int offset,Int limit){
    table:=getTable(obj.typeof)
    return ret{
      this.executor.selectId(table,this.db,obj,orderby,offset,limit)
    }
  }
  ** convert id list to object list
  private Obj[] idToObj(Type type,Obj[] ids){
    Obj[] list:=[,]
    ids.each{
      instance:=findById(type,it)
      if(instance!=null){
        list.add(instance)
      }
    }
    return list
  }
  
  ////////////////////////////////////////////////////////////////////////
  //select where
  ////////////////////////////////////////////////////////////////////////
  
  ** query by condition
  Obj[] selectWhere(Type type,Str where,Int offset:=0,Int limit:=20){
    Obj[]? ids:=getWhereIdList(type,where,offset,limit)
    return idToObj(type,ids)
  }
  ** query id list by condition
  protected virtual Obj[] getWhereIdList(Type type,Str where,Int offset,Int limit){
    table:=getTable(type)
    return ret{
      this.executor.selectWhere(table,this.db,where,offset,limit)
    }
  }
  
  ////////////////////////////////////////////////////////////////////////
  //by ID
  ////////////////////////////////////////////////////////////////////////
  
  virtual Obj? findById(Type type,Obj id){
    table:=getTable(type)
    return ret{
      this.executor.findById(table,this.db,id)
    }
  }
  ** get object id value by mapping table
  Obj? getId(Obj obj){
    table:=getTable(obj.typeof)
    return table.id.field.get(obj)
  }

  ////////////////////////////////////////////////////////////////////////
  //extend method
  ////////////////////////////////////////////////////////////////////////
  ** count by example
  virtual Int count(Obj obj){
    table:=getTable(obj.typeof)
    return ret{
      this.executor.count(table,this.db,obj)
    }
  }
  
  ** exist by example,this op noCache
  Bool exist(Obj obj){
    table:=getTable(obj.typeof)
    n:= ret{this.executor.count(table,this.db,obj)}
    return n>0
  }
  
  ** update or insert
  Void save(Obj obj){
    if(existById(obj)){
      update(obj)
    }else{
      insert(obj)
    }
  }
  private Bool existById(Obj obj){
    table:=getTable(obj.typeof)
    id:=table.id.field.get(obj)
    if(findById(obj.typeof,id)!=null){
      return true
    }
    return false
  }
  
  ////////////////////////////////////////////////////////////////////////
  //table operate
  ////////////////////////////////////////////////////////////////////////
  
  Void createTable(Type type){
    table:=getTable(type)
    use{
      this.executor.createTable(table,this.db)
    }
  }
  
  Void dropTable(Type type){
    table:=getTable(type)
    use{
      this.executor.dropTable(table,this.db)
    }
  }
  
  Bool tableExists(Type type){
    table:=getTable(type)
    return ret{
      this.db.tableExists(table.name)
    }
  }
  
  ** check the object table is fit to database table
  Bool checkTable(Table table){
    return ret|c->Obj?|{
      trow:=this.db.tableRow(table.name)
      return table.checkMatchDb(trow.cols)
    }
  }
  
  **
  ** try create the table,if noMatchDatabase throw a MappingErr
  ** 
  Void tryCreateAllTable(){
    use{
      this.tables.vals.each|Table t|{
        if(this.db.tableExists(t.name)){
          if(!checkTable(t)){
            throw MappingErr("table $t.name not match the database")
          }
        }else{
          this.executor.createTable(t,this.db)
        }
      }
    }
  }
  
  **drop all table with in appliction
  Void dropAllTable(){
    use{
      this.tables.vals.each|Table t|{
        if(this.db.tableExists(t.name)){
          this.executor.dropTable(t,this.db)
        }
      }
    }
  }
  
  **drop all tables in the database
  Void clearDatabase(){
    use{
      this.executor.clearDatabase(this.db)
    }
  }
  
  ////////////////////////////////////////////////////////////////////////
  //transaction
  ////////////////////////////////////////////////////////////////////////
  
  ** transaction , if error will auto roolback
  virtual Void trans(|This| f){
    use{
      oauto:=this.db.autoCommit
      try{
        this.db.autoCommit=false
        
        f(this)
        this.db.commit
        
      }catch(Err e){
        this.db.rollback
        throw e
      }finally{
        this.db.autoCommit=oauto
      }
    }
  }
}
