import { SenziioSSE } from 'senziio-capacitor-sse';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    SenziioSSE.echo({ value: inputValue })
}
