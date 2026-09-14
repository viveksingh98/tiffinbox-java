// probe.jsh — the capstone's own classes, live, with no main method and no rebuild.
//   jshell -q --class-path ../c2-capstone/target/classes:../c2-capstone/target/lib/* probe.jsh
import com.tiffinbox.*
var db = new Database("jdbc:h2:mem:probe;DB_CLOSE_DELAY=-1")
db.createAndSeed()
var repo = new CustomerRepository(db)
repo.monthRevenue()
repo.findAll().size()
new Dashboard(repo).load()
/exit
