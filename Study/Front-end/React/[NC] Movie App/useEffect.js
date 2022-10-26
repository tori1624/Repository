import { useState, useEffect } from "react";
import Button from "./Button";

function App() {
  const [counter, setValue] = useState(0);
  const [keyword, setKeyword] = useState("");
  const onClick = () => setValue(prev => prev + 1);
  const onChange = (event) => setKeyword(event.target.value);
  console.log("I run all the time.");
  useEffect(() => {
    console.log("I run only once.");
  }, []); // 처음 render될 때만
  useEffect(() => {
    console.log("I run when 'keyword' changes.");
  }, [keyword]); // keyword가 바뀔 때
  useEffect(() => {
    console.log("I run when 'counter' changes.");
  }, [counter]); // counter가 바뀔 때
  useEffect(() => {
    console.log("I run when 'keyword & counter' changes.");
  }, [keyword, counter]); // keyword나 counter가 바뀔 때
  return (
    <div>
      <input
        value={keyword}
        onChange={onChange} 
        type="text" 
        placeholder="Search here" 
      />
      <h1>{counter}</h1>
      <Button text={"Click me"} onClick={onClick} />
    </div>
  );
}

export default App;
