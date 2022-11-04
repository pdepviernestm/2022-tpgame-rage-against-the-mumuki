import wollok.game.*

object juego{
	var modificadorVelocidad = 0
	var pos = game.at(0,0)
	var indiceSeleccion = 0
	var menu = true
	const posiblesAutos = ["./assets/autoAstonMartin.png", "./assets/ferrariRojoR.png", "./assets/bugattiAzulR.png", "./assets/lamboVerdeR.png"]
	const posiblesObstaculos = ["./assets/camionetaNegra.png", "./assets/autoRojoObstaculoR.png", "./assets/obstaculo gris R.png"]
	method configurar(){
		game.width(8)
		game.height(8)
		game.title("Acceso Oeste")
		game.cellSize(100)
		game.boardGround("./assets/pista.jpg")
		game.addVisual(menuEleccion)
		game.addVisual(auto)
		keyboard.space().onPressDo{menu = false self.jugar()} 
		keyboard.left().onPressDo{ if(menu) self.cambiarAutoI() else auto.moverIzquierda()}
		keyboard.right().onPressDo{if(menu) self.cambiarAutoD()  else auto.moverDerecha()}
		game.whenCollideDo(auto,{ unObjeto=> 
		game.removeTickEvent("aparece Obstaculo")
		if(score.puntaje() >= 10) game.removeTickEvent("generador de obstaculos especiales")		
		game.clear()
		score.position(game.center().down(1))
		game.addVisual(score)
		game.addVisual(guiguitty)
		guiguitty.gifear()
		game.addVisual(gameOver)
		game.schedule(2000,{ => game.stop()})
		})
		game.start()
	}
	
	method cambiarAutoI(){
		if(indiceSeleccion != 0){
			indiceSeleccion -= 1
			auto.image(posiblesAutos.get(indiceSeleccion))					
		} 
	}
	method cambiarAutoD(){
		if(indiceSeleccion < posiblesAutos.size() - 1){
			indiceSeleccion += 1
			auto.image(posiblesAutos.get(indiceSeleccion))
		} 
	}
	
	method jugar(){
		game.removeVisual(menuEleccion)
		game.addVisual(score)
		game.onTick(400,"aparece Obstaculo", {
			new Obstaculo(image = posiblesObstaculos.get(0.randomUpTo(posiblesObstaculos.size() - 1 )),
				position=game.at((2.randomUpTo(game.width() - 1)),game.height() - 1)
			).aparecer()
			modificadorVelocidad += 0.5
			score.aumentar()
			if(score.puntaje() == 10) 
				game.onTick(8000, "generador de obstaculos especiales", {
					pos = game.at((2.randomUpTo(game.width() - 1)),game.height() - 1)
					if(game.getObjectsIn(pos) != null){
						if(pos.left(1).x() > 2) pos = pos.left(1)
						else pos = pos.right(1)
					}
					new ObstaculoEspecial(image =  "./assets/policiaR.png", position = pos
					).aparecer()			
				})
			
			
		})
	}

	method modificadorVelocidad() = modificadorVelocidad	
}

object gameOver {
	method position() = game.center()
	method text() = "GAME OVER"
	method textColor() = "#000000"
}

object guiguitty {
	const gifguiguitty = ["./assets/guiguitty0.jpg", "./assets/guiguitty1.jpg", "./assets/guiguitty2.jpg"]
	var property image = "./assets/guiguitty0.jpg"
	var index = 0
	var paraAtras = false
	method position() = game.center().up(1).left(1)
	method gifear(){
		game.schedule(125, {
			if(index == 0){
				image = gifguiguitty.get(1)
				index = 1
				paraAtras = false
			}
			if(index == 1){
				if(paraAtras){
					image = gifguiguitty.get(0)
					index = 0
				}
				else{
					image = gifguiguitty.get(2)
					index = 2
				}
			}
			if(index == 2){
				image = gifguiguitty.get(1)
				index = 1
				paraAtras = true
			}
			self.gifear()		
		})
		
	}
	
}


object menuEleccion {
	method position() = game.center()
	method text() = "Elegir vehiculo con <- ->\n Toca espacio para comenzar"
	method textColor() = "#000000"
}

object score {
	var puntaje = 0
	var property position = game.at(game.width() - 1 ,game.height() - 1)
	method text() = "Score: " + puntaje.truncate(0).toString()
	method aumentar(){ puntaje += 0.2 }
	method puntaje() = puntaje.truncate(0)
	method textColor() = "#000000"
}

object auto{
	var property image = "./assets/autoAstonMartin.png"
	var property position = game.at(game.center().x(),0)
	method moverDerecha(){
	if(self.position().x() < game.width() - 2) position = position.right(1) 
	}
	method moverIzquierda(){
	if(self.position().x() > 2) position = position.left(1)
	} 
}

class Obstaculo{
	var property image
	var property position  
	method aparecer(){

	game.addVisual(self)
	self.mover()
	}
	method mover(){
		game.schedule(62.max(125 - juego.modificadorVelocidad()),{
			if(self.position().y() == 0) game.removeVisual(self)
			else {
				position = position.down(1)
				self.mover()
			}
		}) 
		
		
	}
}

class ObstaculoEspecial inherits Obstaculo{
	var valorRandom = 1
	override method mover(){
		valorRandom = 1.randomUpTo(2)
		if (valorRandom == 2 and game.getObjectsIn(position.left(1)) == null and position.left(1).x() > 2) position = position.left(1)
		else if(valorRandom == 2 and game.getObjectsIn(position.right(1)) == null and position.right(1).x() < game.width() - 2) position = position.right(1)
		super()		
	}
}

