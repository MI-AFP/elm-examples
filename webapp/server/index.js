const express = require('express')
const bodyParser = require('body-parser')


const users = [{
    'username': 'slifkjan',
    'password': 'password',
    'token': 'gJ2oS3pCnqy9GyQp4drN',
    'name': 'Jan Slifka'
}]


const app = express()


app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*')
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept')
    res.header('Access-Control-Allow-Methods', 'PUT, POST, GET, DELETE, OPTIONS')
    next()
})

app.use(bodyParser.json())


app.post('/users/token', (req, res) => {
    const user = users.find(u => u.username === req.body.username && u.password === req.body.password)
    if (user !== undefined) {
        res.send({ token: user.token })
    } else {
        res.status(400).send()
    }
})


app.get('/users/current', (req, res) => {
    const authorization = req.header('authorization')
    const user = users.find(u => `Bearer ${u.token}` === authorization)
    if (user !== undefined) {
        res.send({ username: user.username, name: user.name })
    } else {
        res.status(401).send()
    }
})


app.listen(3000)
